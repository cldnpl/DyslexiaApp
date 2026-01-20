//
//  SpeechSynthesizer.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 15/01/26.
//

import Foundation
import AVFoundation
import Combine

// speechsynthesizer gestisce lettura testo
class SpeechSynthesizer: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer() //synthesizer è colui che legge, AVSpeech etc è il lettore di Apple
    @Published var isPlaying = false
    @Published var isPaused = false
    @Published var currentWordIndex: Int = 0
    
    var words: [String] = []
    var wordRanges: [NSRange] = []
    var originalWords: [String] = [] // Parole originali per mappare gli indici
    var originalWordRanges: [NSRange] = [] // Range originali per l'evidenziazione
    var fullText: String = ""
    var startWordIndex: Int = 0 // Indice di partenza quando salto a una parola
    var onWordChanged: ((Int) -> Void)?
    var onPlaybackStateChanged: ((Bool) -> Void)?
    
    private var currentUtterance: AVSpeechUtterance?
    private var currentRate: Float = 0.5
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func setupText(_ text: String) {
        fullText = text
        words = text.components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            .filter { !$0.isEmpty && $0.trimmingCharacters(in: .whitespaces).count > 0 }
        
        // Salva sempre le parole e i range originali
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
        
        // Usa sempre il testo originale completo per i range
        setupText(originalText)
        currentWordIndex = index
        
        // Notifica il cambio di parola per aggiornare l'evidenziazione
        onWordChanged?(index)
    }
    
    func speak(text: String, rate: Float) {
        stop()
        setupText(text)
        currentRate = rate
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        utterance.voice = AVSpeechSynthesisVoice(language: "it-IT")
        
        currentUtterance = utterance
        synthesizer.speak(utterance)
        isPlaying = true
        isPaused = false
        onPlaybackStateChanged?(true)
    }
    
    func pause() {
        // Controlla lo stato reale del synthesizer
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .immediate)
            isPlaying = false
            isPaused = true
            onPlaybackStateChanged?(false)
        } else if isPlaying {
            // Se lo stato interno dice che sta riproducendo ma il synthesizer no, sincronizza
            isPlaying = false
            isPaused = true
            onPlaybackStateChanged?(false)
        }
    }
    
    func resume() {
        if synthesizer.isPaused {
            synthesizer.continueSpeaking()
            isPlaying = true
            isPaused = false
            onPlaybackStateChanged?(true)
        }
    }
    
    func stop() {
        // Ferma la riproduzione solo se sta effettivamente parlando
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // Sincronizza sempre lo stato interno
        isPlaying = false
        isPaused = false
        currentWordIndex = 0
        currentUtterance = nil
        onPlaybackStateChanged?(false)
    }
    
    func skipForward(seconds: Double) {
        guard !originalWords.isEmpty else { return }
        
        // Calcola approssimativamente quante parole corrispondono a 10 secondi
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
    
    private func jumpToWord(at index: Int) {
        guard index < originalWords.count && index >= 0 else { return }
        
        let wasPlaying = isPlaying
        stop()
        
        // Salva l'indice di partenza per mappare correttamente
        startWordIndex = index
        currentWordIndex = index
        
        // Ricrea il testo dalla parola corrente in poi usando le parole originali
        let remainingWords = Array(originalWords[index...])
        let remainingText = remainingWords.joined(separator: " ")
        
        if !remainingText.isEmpty {
            // Aggiorna le parole per la lettura (solo per il testo rimanente)
            words = remainingWords
            
            // Ricalcola i range per il testo rimanente (solo per il delegate)
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
                utterance.voice = AVSpeechSynthesisVoice(language: "it-IT")
                currentUtterance = utterance
                synthesizer.speak(utterance)
                isPlaying = true
                isPaused = false
                onPlaybackStateChanged?(true)
            }
        }
    }
    
    // Metodi delegate per tracciare quale parola sta leggendo
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        // Sincronizza lo stato quando inizia effettivamente a parlare
        DispatchQueue.main.async {
            if !self.isPlaying && synthesizer.isSpeaking {
                self.isPlaying = true
                self.isPaused = false
                self.onPlaybackStateChanged?(true)
            }
        }
        
        // Trova quale parola corrisponde a questo range nel testo rimanente
        for (index, wordRange) in wordRanges.enumerated() {
            if NSIntersectionRange(wordRange, characterRange).length > 0 {
                // Mappa l'indice del testo rimanente all'indice originale
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
