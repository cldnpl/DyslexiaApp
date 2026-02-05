//
//  TextCorrectionHelper.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 18/01/26.
//

import Foundation
import UIKit
import NaturalLanguage

class TextCorrectionHelper {
    // MARK: - Public Methods
    
    static func correctText(
        _ text: String,
        progressCallback: @escaping @Sendable (Double, String) -> Void,
        completion: @escaping @Sendable (String?) -> Void
    ) {
        guard !text.isEmpty else {
            completion("")
            return
        }
        
        // Esegui tutto su background thread
        Task.detached(priority: .userInitiated) {
            await performLocalCorrection(text, progressCallback: progressCallback, completion: completion)
        }
    }
    
    // MARK: - Apple Native Correction (Offline)
    
    private static func performLocalCorrection(
        _ text: String,
        progressCallback: @escaping @Sendable (Double, String) -> Void,
        completion: @escaping @Sendable (String?) -> Void
    ) async {
        
        // Progress: 0.1
        progressCallback(0.1, "Recognizing the language...")
        
        // Detect text language
        let language = await detectLanguage(text)
        
        // Progress: 0.2
        progressCallback(0.2, "Spell checking...")
        
        // Spell correction with UITextChecker (must run on main thread)
        let corrected = await correctSpelling(text, language: language)
        
        var finalCorrected = corrected
        
        // Progress: 0.5
        progressCallback(0.5, "Cleaning formatting...")
        
        // Basic formatting cleanup (non richiede main thread)
        finalCorrected = cleanFormatting(finalCorrected)
        
        // Progress: 0.7
        progressCallback(0.7, "Correcting punctuation...")
        
        // Punctuation correction (non richiede main thread)
        finalCorrected = correctPunctuation(finalCorrected)
        
        // Progress: 0.9
        progressCallback(0.9, "Finalizing...")
        
        // Capitalization (non richiede main thread)
        finalCorrected = capitalizeSentences(finalCorrected)
        
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Progress: 1.0
        progressCallback(1.0, "Completed!")
        completion(finalCorrected)
    }
    
    // MARK: - Helper Methods
    
    /// Detects text language using Natural Language Framework
    private static func detectLanguage(_ text: String) async -> String {
        // Quick check for Chinese characters
        let chineseCharacterSet = CharacterSet(charactersIn: "\u{4E00}"..."\u{9FFF}")
        if text.rangeOfCharacter(from: chineseCharacterSet) != nil {
            let chineseCharCount = text.unicodeScalars.filter { chineseCharacterSet.contains($0) }.count
            let punctuationSet = CharacterSet.punctuationCharacters
            let whitespaceSet = CharacterSet.whitespacesAndNewlines
            let totalCharCount = text.unicodeScalars.filter { !whitespaceSet.contains($0) && !punctuationSet.contains($0) }.count
            if totalCharCount > 0 && Double(chineseCharCount) / Double(totalCharCount) > 0.3 {
                return "zh-Hans"
            }
        }
        
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        if let dominantLanguage = recognizer.dominantLanguage {
            if dominantLanguage == .simplifiedChinese {
                return "zh-Hans"
            }
            if dominantLanguage == .traditionalChinese {
                return "zh-Hant"
            }
            
            let langCode = dominantLanguage.rawValue
            
            // Verifica supporto su main thread
            let isSupported = await MainActor.run {
                isLanguageSupportedByTextChecker(langCode)
            }
            
            if isSupported {
                return normalizeLanguageCode(langCode)
            }
        }
        
        // Try alternative languages
        let languageHypotheses = recognizer.languageHypotheses(withMaximum: 5)
        for (language, confidence) in languageHypotheses.sorted(by: { $0.value > $1.value }) {
            if language == .simplifiedChinese { return "zh-Hans" }
            if language == .traditionalChinese { return "zh-Hant" }
            
            let langCode = language.rawValue
            if confidence > 0.1 {
                let isSupported = await MainActor.run {
                    isLanguageSupportedByTextChecker(langCode)
                }
                if isSupported {
                    return normalizeLanguageCode(langCode)
                }
            }
        }
        
        // Default: English
        return "en"
    }
    
    /// Checks if a language is Chinese
    private static func isChineseLanguage(_ languageCode: String) -> Bool {
        let code = languageCode.lowercased()
        return code == "zh-hans" || code == "zh-hant" ||
               code == "simplifiedchinese" || code == "traditionalchinese" ||
               code.hasPrefix("zh")
    }
    
    /// Checks if a language is supported by UITextChecker
    @MainActor
    private static func isLanguageSupportedByTextChecker(_ languageCode: String) -> Bool {
        let availableLanguages = UITextChecker.availableLanguages
        let normalizedCode = normalizeLanguageCode(languageCode)
        let baseCode = normalizedCode.contains("-") ? String(normalizedCode.split(separator: "-").first ?? "") : normalizedCode
        
        for availableLang in availableLanguages {
            let availableBase = availableLang.contains("-") ? String(availableLang.split(separator: "-").first ?? "") : availableLang
            if availableLang.lowercased() == normalizedCode.lowercased() ||
               availableBase.lowercased() == baseCode.lowercased() {
                return true
            }
        }
        
        let nllanguageCodes = getAllNLLanguageCodes()
        return nllanguageCodes.contains { $0.lowercased() == baseCode.lowercased() }
    }
    
    /// Returns all language codes supported by NLLanguage
    private static func getAllNLLanguageCodes() -> [String] {
        return [
            "en", "fr", "de", "it", "es", "pt", "nl", "sv", "da", "no", "fi",
            "is", "ga", "cy", "eu", "ca", "gl", "pl", "cs", "sk", "hu", "ro",
            "bg", "hr", "sr", "sl", "mk", "sq", "el", "ru", "uk", "et", "lv", "lt",
            "ar", "he", "fa", "ur", "hi", "bn", "ta", "te", "ml", "kn", "gu",
            "pa", "mr", "ne", "si", "th", "vi", "id", "ms", "my", "km", "lo",
            "zh", "ja", "ko", "tr", "ka", "hy", "az", "kk", "ky", "uz", "mn",
            "am", "bo", "or", "chr",
            "af", "sw", "zu", "xh", "tn", "st", "ve", "ts", "ss", "nr", "nso"
        ]
    }
    
    /// Corrects spelling using UITextChecker - DEVE girare su MainActor
    @MainActor
    private static func correctSpelling(_ text: String, language: String) async -> String {
        let normalizedLanguage = normalizeLanguageCode(language)
        
        // For Chinese, UITextChecker does not support spell correction
        if isChineseLanguage(normalizedLanguage) {
            return text
        }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: text.utf16.count)
        var correctedText = text
        var offset = 0
        
        var misspelledRange = checker.rangeOfMisspelledWord(
            in: text,
            range: range,
            startingAt: 0,
            wrap: false,
            language: normalizedLanguage
        )
        
        var correctionCount = 0
        let maxCorrections = 1000
        
        while misspelledRange.location != NSNotFound && correctionCount < maxCorrections {
            let misspelledWord = (text as NSString).substring(with: misspelledRange)
            
            if misspelledWord.count < 2 || misspelledWord.rangeOfCharacter(from: CharacterSet.letters) == nil {
                let nextLocation = misspelledRange.location + misspelledRange.length
                misspelledRange = checker.rangeOfMisspelledWord(
                    in: text,
                    range: NSRange(location: nextLocation, length: text.utf16.count - nextLocation),
                    startingAt: 0,
                    wrap: false,
                    language: normalizedLanguage
                )
                continue
            }
            
            var guesses = checker.guesses(
                forWordRange: misspelledRange,
                in: text,
                language: normalizedLanguage
            )
            
            if guesses?.isEmpty ?? true, normalizedLanguage.contains("-") {
                let baseLanguage = String(normalizedLanguage.split(separator: "-").first ?? "")
                guesses = checker.guesses(
                    forWordRange: misspelledRange,
                    in: text,
                    language: baseLanguage
                )
            }
            
            if let firstGuess = guesses?.first, !firstGuess.isEmpty, firstGuess != misspelledWord {
                let lengthDiff = abs(firstGuess.count - misspelledWord.count)
                if lengthDiff <= 3 || misspelledWord.count < 4 {
                    let correctedRange = NSRange(
                        location: misspelledRange.location + offset,
                        length: misspelledRange.length
                    )
                    correctedText = (correctedText as NSString).replacingCharacters(
                        in: correctedRange,
                        with: firstGuess
                    )
                    offset += (firstGuess.count - misspelledWord.count)
                    correctionCount += 1
                }
            }
            
            let nextLocation = misspelledRange.location + misspelledRange.length
            misspelledRange = checker.rangeOfMisspelledWord(
                in: text,
                range: NSRange(location: nextLocation, length: text.utf16.count - nextLocation),
                startingAt: 0,
                wrap: false,
                language: normalizedLanguage
            )
        }
        
        return correctedText
    }
    
    /// Normalizes language code
    private static func normalizeLanguageCode(_ languageCode: String) -> String {
        let code = languageCode.lowercased()
        
        let languageMap: [String: String] = [
            "zh-hans": "zh-Hans", "zh-hant": "zh-Hant", "zh-cn": "zh-Hans",
            "zh-tw": "zh-Hant", "pt-br": "pt-BR", "pt-pt": "pt-PT",
            "en-us": "en-US", "en-gb": "en-GB", "es-es": "es-ES"
        ]
        
        if let mapped = languageMap[code] {
            return mapped
        }
        
        if code.contains("-") {
            let parts = code.split(separator: "-")
            if parts.count >= 2 {
                let base = String(parts[0])
                let region = String(parts[1])
                return "\(base)-\(region.uppercased())"
            }
            return code
        }
        
        return String(code.prefix(2))
    }
    
    /// Cleans formatting
    private static func cleanFormatting(_ text: String) -> String {
        var cleaned = text
        cleaned = cleaned.replacingOccurrences(of: "  +", with: " ", options: .regularExpression)
        let lines = cleaned.components(separatedBy: .newlines)
        cleaned = lines.map { $0.trimmingCharacters(in: .whitespaces) }.joined(separator: "\n")
        return cleaned
    }
    
    /// Corrects punctuation
    private static func correctPunctuation(_ text: String) -> String {
        var corrected = text
        corrected = corrected.replacingOccurrences(of: " ,", with: ",")
        corrected = corrected.replacingOccurrences(of: " .", with: ".")
        corrected = corrected.replacingOccurrences(of: " ;", with: ";")
        corrected = corrected.replacingOccurrences(of: " :", with: ":")
        corrected = corrected.replacingOccurrences(of: " !", with: "!")
        corrected = corrected.replacingOccurrences(of: " ?", with: "?")
        corrected = corrected.replacingOccurrences(of: ",[^ ]", with: ", ", options: .regularExpression)
        corrected = corrected.replacingOccurrences(of: "\\.[^ ]", with: ". ", options: .regularExpression)
        return corrected
    }
    
    /// Capitalizes sentences
    private static func capitalizeSentences(_ text: String) -> String {
        let sentences = text.components(separatedBy: ". ")
        let capitalizedSentences: [String] = sentences.enumerated().map { index, sentence in
            if index == 0 || !sentence.isEmpty {
                let trimmed = sentence.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty {
                    return String(trimmed.prefix(1).uppercased()) + String(trimmed.dropFirst())
                }
            }
            return sentence
        }
        return capitalizedSentences.joined(separator: ". ")
    }
}
