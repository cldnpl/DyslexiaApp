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
        progressCallback: @escaping (Double, String) -> Void,
        completion: @escaping (String?) -> Void
    ) {
        guard !text.isEmpty else {
            completion("")
            return
        }
        
        // Usa sempre la correzione locale con le API native di Apple (completamente offline)
        performLocalCorrection(text, progressCallback: progressCallback, completion: completion)
    }
    
    // MARK: - Apple Native Correction (Offline)
    
    /// Correzione usando le API native di Apple (UITextChecker e Natural Language Framework)
    private static func performLocalCorrection(
        _ text: String,
        progressCallback: @escaping (Double, String) -> Void,
        completion: @escaping (String?) -> Void
    ) {
        DispatchQueue.main.async {
            progressCallback(0.1, "Riconoscimento lingua...")
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Riconosci la lingua del testo
            let language = detectLanguage(text)
            
            DispatchQueue.main.async {
                progressCallback(0.2, "Correzione ortografica...")
            }
            
            // Correzione ortografica con UITextChecker
            var corrected = correctSpelling(text, language: language)
            
            DispatchQueue.main.async {
                progressCallback(0.5, "Pulizia formattazione...")
            }
            
            // Pulizia formattazione base
            corrected = cleanFormatting(corrected)
            
            DispatchQueue.main.async {
                progressCallback(0.7, "Correzione punteggiatura...")
            }
            
            // Correzione punteggiatura
            corrected = correctPunctuation(corrected)
            
            DispatchQueue.main.async {
                progressCallback(0.9, "Finalizzazione...")
            }
            
            // Capitalizzazione
            corrected = capitalizeSentences(corrected)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                progressCallback(1.0, "Completato!")
                completion(corrected)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Rileva la lingua del testo usando Natural Language Framework con supporto multilingua avanzato
    private static func detectLanguage(_ text: String) -> String {
        // Controllo rapido per caratteri cinesi (CJK Unified Ideographs)
        let chineseCharacterSet = CharacterSet(charactersIn: "\u{4E00}"..."\u{9FFF}")
        if text.rangeOfCharacter(from: chineseCharacterSet) != nil {
            // Se contiene caratteri cinesi, verifica se sono più del 30% del testo
            let chineseCharCount = text.unicodeScalars.filter { chineseCharacterSet.contains($0) }.count
            let punctuationSet = CharacterSet.punctuationCharacters
            let whitespaceSet = CharacterSet.whitespacesAndNewlines
            let totalCharCount = text.unicodeScalars.filter { !whitespaceSet.contains($0) && !punctuationSet.contains($0) }.count
            if totalCharCount > 0 && Double(chineseCharCount) / Double(totalCharCount) > 0.3 {
                // Probabilmente è cinese semplificato (più comune)
                return "zh-Hans"
            }
        }
        
        let recognizer = NLLanguageRecognizer()
        
        // Non impostiamo languageConstraints per supportare tutte le lingue disponibili
        // (di default NLLanguageRecognizer supporta tutte le lingue quando languageConstraints è nil)
        
        recognizer.processString(text)
        
        // Ottieni la lingua dominante con livello di confidenza
        if let dominantLanguage = recognizer.dominantLanguage {
            // Controlla direttamente se è cinese usando l'enum
            if dominantLanguage == .simplifiedChinese {
                return "zh-Hans"
            }
            if dominantLanguage == .traditionalChinese {
                return "zh-Hant"
            }
            
            let langCode = dominantLanguage.rawValue
            // Accetta altre lingue se supportate da UITextChecker
            if isLanguageSupportedByTextChecker(langCode) {
                return normalizeLanguageCode(langCode)
            }
        }
        
        // Se la lingua dominante non è supportata, prova con le lingue alternative
        let languageHypotheses = recognizer.languageHypotheses(withMaximum: 5)
        for (language, confidence) in languageHypotheses.sorted(by: { $0.value > $1.value }) {
            // Controlla direttamente se è cinese usando l'enum
            if language == .simplifiedChinese {
                return "zh-Hans"
            }
            if language == .traditionalChinese {
                return "zh-Hant"
            }
            
            let langCode = language.rawValue
            if confidence > 0.1 && isLanguageSupportedByTextChecker(langCode) {
                return normalizeLanguageCode(langCode)
            }
        }
        
        // Se nessuna lingua è stata rilevata con confidenza, prova a rilevare per segmenti
        let segments = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        if !segments.isEmpty {
            let sampleSize = min(segments.count, 50)
            let sample = segments.prefix(sampleSize).joined(separator: " ")
            
            let segmentRecognizer = NLLanguageRecognizer()
            // Non impostiamo languageConstraints per supportare tutte le lingue disponibili
            segmentRecognizer.processString(sample)
            
            if let segmentLanguage = segmentRecognizer.dominantLanguage {
                // Controlla direttamente se è cinese usando l'enum
                if segmentLanguage == .simplifiedChinese {
                    return "zh-Hans"
                }
                if segmentLanguage == .traditionalChinese {
                    return "zh-Hant"
                }
                
                let langCode = segmentLanguage.rawValue
                if isLanguageSupportedByTextChecker(langCode) {
                    return normalizeLanguageCode(langCode)
                }
            }
        }
        
        // Default: usa la lingua di sistema o inglese come fallback
        if let systemLanguage = Locale.preferredLanguages.first?.prefix(2).lowercased() {
            let systemLangCode = String(systemLanguage)
            if isLanguageSupportedByTextChecker(systemLangCode) {
                return systemLangCode
            }
        }
        
        // Ultimo fallback: inglese (sempre supportato)
        return "en"
    }
    
    /// Verifica se una lingua è cinese (semplificato o tradizionale)
    private static func isChineseLanguage(_ languageCode: String) -> Bool {
        let code = languageCode.lowercased()
        return code == "zh-hans" || code == "zh-hant" || 
               code == "simplifiedchinese" || code == "traditionalchinese" ||
               code.hasPrefix("zh")
    }
    
    /// Verifica se una lingua è supportata da UITextChecker
    private static func isLanguageSupportedByTextChecker(_ languageCode: String) -> Bool {
        // Ottieni dinamicamente tutte le lingue supportate da UITextChecker
        let availableLanguages = UITextChecker.availableLanguages
        
        // Normalizza il codice lingua per il confronto
        let normalizedCode = normalizeLanguageCode(languageCode)
        let baseCode = normalizedCode.contains("-") ? String(normalizedCode.split(separator: "-").first ?? "") : normalizedCode
        
        // Verifica se la lingua è nella lista delle lingue disponibili
        for availableLang in availableLanguages {
            let availableBase = availableLang.contains("-") ? String(availableLang.split(separator: "-").first ?? "") : availableLang
            if availableLang.lowercased() == normalizedCode.lowercased() || 
               availableBase.lowercased() == baseCode.lowercased() {
                return true
            }
        }
        
        // Se non trovata, verifica se è una delle lingue supportate da NLLanguage
        // Lista completa di tutte le lingue supportate da NLLanguage
        let nllanguageCodes = getAllNLLanguageCodes()
        return nllanguageCodes.contains { $0.lowercased() == baseCode.lowercased() }
    }
    
    /// Restituisce tutti i codici lingua supportati da NLLanguage
    private static func getAllNLLanguageCodes() -> [String] {
        // Lista COMPLETA di tutte le lingue supportate da NLLanguage
        // Basata sulla documentazione ufficiale di Apple Natural Language Framework
        return [
            // Lingue principali europee
            "en", "fr", "de", "it", "es", "pt", "nl", "sv", "da", "no", "fi",
            "is", "ga", "cy", "eu", "ca", "gl", "pl", "cs", "sk", "hu", "ro",
            "bg", "hr", "sr", "sl", "mk", "sq", "el", "ru", "uk", "et", "lv", "lt",
            
            // Lingue mediorientali e asiatiche
            "ar", "he", "fa", "ur", "hi", "bn", "ta", "te", "ml", "kn", "gu",
            "pa", "mr", "ne", "si", "th", "vi", "id", "ms", "my", "km", "lo",
            "zh", "ja", "ko", "tr", "ka", "hy", "az", "kk", "ky", "uz", "mn",
            "am", "bo", "or", "chr",
            
            // Lingue africane
            "af", "sw", "zu", "xh", "tn", "st", "ve", "ts", "ss", "nr", "nso"
        ]
    }
    
    /// Corregge l'ortografia usando UITextChecker con supporto multilingua avanzato
    private static func correctSpelling(_ text: String, language: String) -> String {
        // Normalizza il codice lingua (rimuovi varianti regionali se necessario)
        let normalizedLanguage = normalizeLanguageCode(language)
        
        // Per il cinese, UITextChecker non supporta la correzione ortografica
        // Restituiamo il testo originale (verrà comunque pulito dalla formattazione)
        if isChineseLanguage(normalizedLanguage) {
            return text
        }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: text.utf16.count)
        var correctedText = text
        var offset = 0
        
        // Trova tutte le parole errate
        var misspelledRange = checker.rangeOfMisspelledWord(
            in: text,
            range: range,
            startingAt: 0,
            wrap: false,
            language: normalizedLanguage
        )
        
        var correctionCount = 0
        let maxCorrections = 1000 // Limite per evitare loop infiniti
        
        while misspelledRange.location != NSNotFound && correctionCount < maxCorrections {
            // Ottieni i suggerimenti per la parola errata
            let misspelledWord = (text as NSString).substring(with: misspelledRange)
            
            // Ignora parole molto corte o che contengono solo numeri/punteggiatura
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
            
            // Prova prima con la lingua specificata
            var guesses = checker.guesses(
                forWordRange: misspelledRange,
                in: text,
                language: normalizedLanguage
            )
            
            // Se non ci sono suggerimenti, prova con la lingua base (senza variante regionale)
            if guesses?.isEmpty ?? true, normalizedLanguage.contains("-") {
                let baseLanguage = String(normalizedLanguage.split(separator: "-").first ?? "")
                guesses = checker.guesses(
                    forWordRange: misspelledRange,
                    in: text,
                    language: baseLanguage
                )
            }
            
            // Usa il primo suggerimento se disponibile e ha senso
            if let firstGuess = guesses?.first, !firstGuess.isEmpty, firstGuess != misspelledWord {
                // Verifica che il suggerimento sia ragionevole (stessa lunghezza approssimativa)
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
            
            // Cerca la prossima parola errata
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
    
    /// Normalizza il codice lingua per compatibilità con UITextChecker
    private static func normalizeLanguageCode(_ languageCode: String) -> String {
        // UITextChecker usa codici lingua ISO 639-1 (2 caratteri) o con varianti regionali
        // Alcuni codici potrebbero avere formati diversi, normalizziamoli
        
        let code = languageCode.lowercased()
        
        // Mappa COMPLETA di codici comuni che potrebbero avere varianti
        // Include tutte le lingue supportate da NLLanguage e UITextChecker
        let languageMap: [String: String] = [
            // Cinese (varianti)
            "zh-hans": "zh-Hans", "zh-hant": "zh-Hant", "zh-cn": "zh-Hans",
            "zh-tw": "zh-Hant", "zh-hk": "zh-Hant", "zh-mo": "zh-Hant",
            "simplifiedchinese": "zh-Hans", "traditionalchinese": "zh-Hant",
            
            // Portoghese
            "pt-br": "pt-BR", "pt-pt": "pt-PT",
            
            // Spagnolo
            "es-es": "es-ES", "es-mx": "es-MX", "es-ar": "es-AR", "es-co": "es-CO",
            "es-cl": "es-CL", "es-pe": "es-PE", "es-ve": "es-VE",
            
            // Inglese
            "en-us": "en-US", "en-gb": "en-GB", "en-au": "en-AU", "en-ca": "en-CA",
            "en-nz": "en-NZ", "en-ie": "en-IE", "en-za": "en-ZA",
            
            // Francese
            "fr-fr": "fr-FR", "fr-ca": "fr-CA", "fr-be": "fr-BE", "fr-ch": "fr-CH",
            
            // Tedesco
            "de-de": "de-DE", "de-at": "de-AT", "de-ch": "de-CH",
            
            // Italiano
            "it-it": "it-IT", "it-ch": "it-CH",
            
            // Russo
            "ru-ru": "ru-RU", "ru-by": "ru-BY", "ru-kz": "ru-KZ",
            
            // Giapponese
            "ja-jp": "ja-JP",
            
            // Coreano
            "ko-kr": "ko-KR",
            
            // Arabo
            "ar-sa": "ar-SA", "ar-ae": "ar-AE", "ar-eg": "ar-EG", "ar-iq": "ar-IQ",
            "ar-jo": "ar-JO", "ar-kw": "ar-KW", "ar-lb": "ar-LB", "ar-om": "ar-OM",
            "ar-qa": "ar-QA", "ar-sy": "ar-SY", "ar-tn": "ar-TN", "ar-ye": "ar-YE",
            
            // Hindi
            "hi-in": "hi-IN",
            
            // Norvegese
            "no-no": "no-NO", "nb-no": "no-NO", "nn-no": "no-NO",
            
            // Svedese
            "sv-se": "sv-SE", "sv-fi": "sv-FI",
            
            // Danese
            "da-dk": "da-DK",
            
            // Finlandese
            "fi-fi": "fi-FI",
            
            // Islandese
            "is-is": "is-IS",
            
            // Olandese
            "nl-nl": "nl-NL", "nl-be": "nl-BE",
            
            // Polacco
            "pl-pl": "pl-PL",
            
            // Ceco
            "cs-cz": "cs-CZ",
            
            // Slovacco
            "sk-sk": "sk-SK",
            
            // Ungherese
            "hu-hu": "hu-HU",
            
            // Rumeno
            "ro-ro": "ro-RO",
            
            // Bulgaro
            "bg-bg": "bg-BG",
            
            // Croato
            "hr-hr": "hr-HR",
            
            // Serbo
            "sr-rs": "sr-Latn", "sr-cyrl": "sr-Cyrl",
            
            // Sloveno
            "sl-si": "sl-SI",
            
            // Greco
            "el-gr": "el-GR",
            
            // Ebraico
            "he-il": "he-IL",
            
            // Persiano/Farsi
            "fa-ir": "fa-IR", "fa-af": "fa-AF",
            
            // Urdu
            "ur-pk": "ur-PK", "ur-in": "ur-IN",
            
            // Bengalese
            "bn-bd": "bn-BD", "bn-in": "bn-IN",
            
            // Tamil
            "ta-in": "ta-IN", "ta-lk": "ta-LK",
            
            // Telugu
            "te-in": "te-IN",
            
            // Malayalam
            "ml-in": "ml-IN",
            
            // Kannada
            "kn-in": "kn-IN",
            
            // Gujarati
            "gu-in": "gu-IN",
            
            // Punjabi
            "pa-in": "pa-IN", "pa-pk": "pa-PK",
            
            // Marathi
            "mr-in": "mr-IN",
            
            // Nepalese
            "ne-np": "ne-NP", "ne-in": "ne-IN",
            
            // Singalese
            "si-lk": "si-LK",
            
            // Thailandese
            "th-th": "th-TH",
            
            // Vietnamita
            "vi-vn": "vi-VN",
            
            // Indonesiano
            "id-id": "id-ID",
            
            // Malese
            "ms-my": "ms-MY", "ms-sg": "ms-SG",
            
            // Birmano
            "my-mm": "my-MM",
            
            // Khmer
            "km-kh": "km-KH",
            
            // Lao
            "lo-la": "lo-LA",
            
            // Georgiano
            "ka-ge": "ka-GE",
            
            // Armeno
            "hy-am": "hy-AM",
            
            // Azero
            "az-az": "az-AZ",
            
            // Kazako
            "kk-kz": "kk-KZ",
            
            // Kirghiso
            "ky-kg": "ky-KG",
            
            // Uzbeko
            "uz-uz": "uz-UZ",
            
            // Mongolo
            "mn-mn": "mn-MN",
            
            // Estone
            "et-ee": "et-EE",
            
            // Lettone
            "lv-lv": "lv-LV",
            
            // Lituano
            "lt-lt": "lt-LT",
            
            // Macedone
            "mk-mk": "mk-MK",
            
            // Albanese
            "sq-al": "sq-AL",
            
            // Maltese
            "mt-mt": "mt-MT",
            
            // Irlandese
            "ga-ie": "ga-IE",
            
            // Gallese
            "cy-gb": "cy-GB",
            
            // Basco
            "eu-es": "eu-ES",
            
            // Catalano
            "ca-es": "ca-ES", "ca-ad": "ca-AD", "ca-fr": "ca-FR",
            
            // Galiziano
            "gl-es": "gl-ES",
            
            // Turco
            "tr-tr": "tr-TR",
            
            // Ucraino
            "uk-ua": "uk-UA",
            
            // Amharico
            "am-et": "am-ET",
            
            // Tibetano
            "bo-cn": "bo-CN", "bo-in": "bo-IN",
            
            // Odia/Oriya
            "or-in": "or-IN",
            
            // Cherokee
            "chr-us": "chr-US",
            
            // Africano
            "af-za": "af-ZA",
            
            // Swahili
            "sw-ke": "sw-KE", "sw-tz": "sw-TZ", "sw-ug": "sw-UG",
            
            // Zulu
            "zu-za": "zu-ZA",
            
            // Xhosa
            "xh-za": "xh-ZA",
            
            // Tswana
            "tn-za": "tn-ZA", "tn-bw": "tn-BW",
            
            // Sotho del Sud
            "st-za": "st-ZA", "st-ls": "st-LS",
            
            // Venda
            "ve-za": "ve-ZA",
            
            // Tsonga
            "ts-za": "ts-ZA",
            
            // Swati
            "ss-za": "ss-ZA", "ss-sz": "ss-SZ",
            
            // Ndebele del Sud
            "nr-za": "nr-ZA",
            
            // Sotho del Nord
            "nso-za": "nso-ZA"
        ]
        
        if let mapped = languageMap[code] {
            return mapped
        }
        
        // Se contiene un trattino, mantieni il formato ma normalizza la capitalizzazione
        if code.contains("-") {
            let parts = code.split(separator: "-")
            if parts.count >= 2 {
                let base = String(parts[0])
                let region = String(parts[1])
                return "\(base)-\(region.uppercased())"
            }
            return code
        }
        
        // Altrimenti, restituisci il codice base a 2 caratteri
        return String(code.prefix(2))
    }
    
    /// Pulisce la formattazione (spazi multipli, ecc.)
    private static func cleanFormatting(_ text: String) -> String {
        var cleaned = text
        
        // Rimuovi spazi multipli
        cleaned = cleaned.replacingOccurrences(of: "  +", with: " ", options: .regularExpression)
        
        // Rimuovi spazi all'inizio e alla fine delle righe
        let lines = cleaned.components(separatedBy: .newlines)
        cleaned = lines.map { $0.trimmingCharacters(in: .whitespaces) }
            .joined(separator: "\n")
        
        return cleaned
    }
    
    /// Corregge la punteggiatura
    private static func correctPunctuation(_ text: String) -> String {
        var corrected = text
        
        // Rimuovi spazi prima della punteggiatura
        corrected = corrected.replacingOccurrences(of: " ,", with: ",")
        corrected = corrected.replacingOccurrences(of: " .", with: ".")
        corrected = corrected.replacingOccurrences(of: " ;", with: ";")
        corrected = corrected.replacingOccurrences(of: " :", with: ":")
        corrected = corrected.replacingOccurrences(of: " !", with: "!")
        corrected = corrected.replacingOccurrences(of: " ?", with: "?")
        
        // Aggiungi spazio dopo la punteggiatura se mancante
        corrected = corrected.replacingOccurrences(of: ",[^ ]", with: ", ", options: .regularExpression)
        corrected = corrected.replacingOccurrences(of: "\\.[^ ]", with: ". ", options: .regularExpression)
        
        return corrected
    }
    
    /// Capitalizza le frasi
    private static func capitalizeSentences(_ text: String) -> String {
        let sentences = text.components(separatedBy: ". ")
        let capitalizedSentences = sentences.enumerated().map { index, sentence in
            if index == 0 || !sentence.isEmpty {
                let trimmed = sentence.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty {
                    return trimmed.prefix(1).uppercased() + trimmed.dropFirst()
                }
            }
            return sentence
        }
        return capitalizedSentences.joined(separator: ". ")
    }
}
