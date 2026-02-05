//
//  SpeechSynthesizer.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 15/01/26.
//

import Foundation
import AVFoundation
import Combine
import NaturalLanguage

// SpeechSynthesizer handles text-to-speech
final class SpeechSynthesizer: NSObject, ObservableObject, AVSpeechSynthesizerDelegate, @unchecked Sendable {
    private let synthesizer = AVSpeechSynthesizer() // synthesizer does the reading, AVSpeech is Apple's TTS engine
    private nonisolated(unsafe) var detectedLanguage: String = "en-US" // Detected language, default English
    
    @Published var isPlaying = false
    @Published var isPaused = false
    @Published var currentWordIndex: Int = 0
    
    var words: [String] = []
    var wordRanges: [NSRange] = []
    var originalWords: [String] = [] // Original words to map indices
    var originalWordRanges: [NSRange] = [] // Original ranges for highlighting
    var fullText: String = ""
    var startWordIndex: Int = 0 // Start index when jumping to a word
    var onWordChanged: ((Int) -> Void)?
    var onPlaybackStateChanged: ((Bool) -> Void)?
    
    private var currentUtterance: AVSpeechUtterance?
    private var currentRate: Float = 0.5
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func setupText(_ text: String) {
        // Detect text language
        detectedLanguage = detectLanguage(text)
        
        fullText = text
        words = text.components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            .filter { !$0.isEmpty && $0.trimmingCharacters(in: .whitespaces).count > 0 }
        
        // Always save original words and ranges
        originalWords = words
        wordRanges = []
        originalWordRanges = []
        var currentLocation = 0
        let nsString = text as NSString
        
        for word in words {
            let searchRange = NSRange(location: currentLocation, length: nsString.length - currentLocation)
            let range = nsString.range(of: word, options: [], range: searchRange)
            if range.location != NSNotFound {
                wordRanges.append(range)
                originalWordRanges.append(range)
                currentLocation = range.location + range.length
            }
        }
        
        currentWordIndex = 0
        startWordIndex = 0
    }
    
    func jumpToWordFromOriginal(at index: Int, originalText: String) {
        guard index >= 0 else { return }
        
        stop()
        
        // Always use full original text for ranges
        setupText(originalText)
        currentWordIndex = index
        
        // Notify word change to update highlighting
        onWordChanged?(index)
    }
    
    /// Detects text language using Natural Language Framework
    private func detectLanguage(_ text: String) -> String {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        if let dominantLanguage = recognizer.dominantLanguage {
            let langCode = dominantLanguage.rawValue
            
            let languageMap: [String: String] = [
                "en": "en-US",
                "it": "it-IT",
                "es": "es-ES",
                "fr": "fr-FR",
                "de": "de-DE",
                "pt": "pt-BR",
                "zh-Hans": "zh-CN",
                "zh-Hant": "zh-TW",
                "ja": "ja-JP",
                "ko": "ko-KR",
                "ru": "ru-RU",
                "ar": "ar-SA",
                "hi": "hi-IN",
                "nl": "nl-NL",
                "pl": "pl-PL",
                "tr": "tr-TR",
                "sv": "sv-SE",
                "da": "da-DK",
                "no": "nb-NO",
                "fi": "fi-FI",
                "cs": "cs-CZ",
                "hu": "hu-HU",
                "ro": "ro-RO",
                "el": "el-GR",
                "he": "he-IL",
                "th": "th-TH",
                "vi": "vi-VN",
                "id": "id-ID"
            ]
            
            if let mapped = languageMap[langCode] {
                return mapped
            }
            
            if langCode.contains("-") {
                return langCode
            }
            
            let availableVoices = AVSpeechSynthesisVoice.speechVoices()
            for voice in availableVoices {
                if voice.language.hasPrefix(langCode) {
                    return voice.language
                }
            }
        }
        
        // Fallback: English (default)
        return "en-US"
    }
    
    func speak(text: String, rate: Float) {
        stop()
        setupText(text)
        currentRate = rate
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        
        // Use automatically detected language
        if let voice = AVSpeechSynthesisVoice(language: detectedLanguage) {
            utterance.voice = voice
        } else {
            // Fallback if voice is not available
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        
        currentUtterance = utterance
        synthesizer.speak(utterance)
        isPlaying = true
        isPaused = false
        onPlaybackStateChanged?(true)
    }
    
    func pause() {
        // Check actual synthesizer state
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .immediate)
            isPlaying = false
            isPaused = true
            onPlaybackStateChanged?(false)
        } else if isPlaying {
            // If internal state says playing but synthesizer doesn't, sync
            isPlaying = false
            isPaused = true
            onPlaybackStateChanged?(false)
        }
    }
    
    func resume(rate: Float? = nil) {
        if synthesizer.isPaused {
            // If a rate is provided, always resume from current word at that rate
            // This ensures that if rate was changed during pause, it gets applied
            if let newRate = rate {
                currentRate = newRate
                let currentIndex = currentWordIndex
                stop()
                // Resume from current word with new rate
                if currentIndex < originalWords.count {
                    jumpToWord(at: currentIndex, shouldResume: true)
                }
            } else {
                // If no rate provided, simply continue from pause
                synthesizer.continueSpeaking()
                isPlaying = true
                isPaused = false
                onPlaybackStateChanged?(true)
            }
        }
    }
    
    func stop() {
        // Stop playback only if actually speaking
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // Always sync internal state
        isPlaying = false
        isPaused = false
        currentWordIndex = 0
        currentUtterance = nil
        onPlaybackStateChanged?(false)
    }
    
    func skipForward(seconds: Double) {
        guard !originalWords.isEmpty else { return }
        
        // Approximate how many words correspond to 10 seconds
        let baseWordsPerSecond = 2.5
        let adjustedWordsPerSecond = baseWordsPerSecond * Double(currentRate) / 0.5
        let wordsToSkip = max(1, Int(adjustedWordsPerSecond * seconds))
        
        let newIndex = min(currentWordIndex + wordsToSkip, originalWords.count - 1)
        jumpToWord(at: newIndex)
    }
    
    func skipBackward(seconds: Double) {
        guard !originalWords.isEmpty else { return }
        
        let baseWordsPerSecond = 2.5
        let adjustedWordsPerSecond = baseWordsPerSecond * Double(currentRate) / 0.5
        let wordsToSkip = max(1, Int(adjustedWordsPerSecond * seconds))
        
        let newIndex = max(currentWordIndex - wordsToSkip, 0)
        jumpToWord(at: newIndex)
    }
    
    /// Changes reading speed and stops playback without restarting
    func changeSpeed(rate: Float) {
        currentRate = rate
        
        // If was playing, stop without restarting
        if isPlaying || isPaused {
            pause()
        }
    }
    
    private func jumpToWord(at index: Int, shouldResume: Bool = false) {
        guard index < originalWords.count && index >= 0 else { return }
        
        let wasPlaying = isPlaying || shouldResume
        stop()
        
        // Save start index to map correctly
        startWordIndex = index
        currentWordIndex = index
        
        // Rebuild text from current word onward using original words
        let remainingWords = Array(originalWords[index...])
        let remainingText = remainingWords.joined(separator: " ")
        
        if !remainingText.isEmpty {
            // Update words for reading (remaining text only)
            words = remainingWords
            
            // Recompute ranges for remaining text (for delegate only)
            var newRanges: [NSRange] = []
            var location = 0
            let nsString = remainingText as NSString
            
            for word in remainingWords {
                let searchRange = NSRange(location: location, length: nsString.length - location)
                let range = nsString.range(of: word, options: [], range: searchRange)
                if range.location != NSNotFound {
                    newRanges.append(range)
                    location = range.location + range.length
                }
            }
            
            wordRanges = newRanges
            
            if wasPlaying {
                let utterance = AVSpeechUtterance(string: remainingText)
                utterance.rate = currentRate
                
                // Use automatically detected language
                if let voice = AVSpeechSynthesisVoice(language: detectedLanguage) {
                    utterance.voice = voice
                } else {
                    // Fallback if voice is not available
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                }
                
                currentUtterance = utterance
                synthesizer.speak(utterance)
                isPlaying = true
                isPaused = false
                onPlaybackStateChanged?(true)
            }
        }
    }
    
    // Delegate methods to track which word is being read
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        // Sync state when actually starts speaking
        let isCurrentlySpeaking = synthesizer.isSpeaking
        DispatchQueue.main.async {
            if !self.isPlaying && isCurrentlySpeaking {
                self.isPlaying = true
                self.isPaused = false
                self.onPlaybackStateChanged?(true)
            }
        }
        
        // Trova quale parola corrisponde a questo range nel testo rimanente
        for (index, wordRange) in wordRanges.enumerated() {
            if NSIntersectionRange(wordRange, characterRange).length > 0 {
                // Map remaining text index to original index
                let originalIndex = startWordIndex + index
                DispatchQueue.main.async {
                    self.currentWordIndex = originalIndex
                    self.onWordChanged?(originalIndex)
                }
                break
            }
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.isPaused = false
            self.currentWordIndex = 0
            self.onPlaybackStateChanged?(false)
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.isPaused = false
            self.onPlaybackStateChanged?(false)
        }
    }
}

