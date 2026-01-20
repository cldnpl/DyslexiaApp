//
//  TextRecognitionHelper.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 15/01/26.
//

import SwiftUI
import Vision
import VisionKit
import PDFKit

class TextRecognitionHelper {
    static func recognizeText(from image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        // Esegui il riconoscimento su un thread in background per non bloccare l'UI
        DispatchQueue.global(qos: .userInitiated).async {
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation],
                      error == nil else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                
                let fullText = recognizedStrings.joined(separator: "\n")
                DispatchQueue.main.async {
                    completion(fullText.isEmpty ? nil : fullText)
                }
            }
            
            request.recognitionLevel = .accurate
            
            // Supporto multilingua: abilita il riconoscimento per TUTTE le lingue supportate
            // Vision Framework supporta automaticamente tutte le lingue quando non si specifica un array
            // Ma per massimizzare l'accuratezza, specifichiamo tutte le lingue principali supportate
            if #available(iOS 13.0, *) {
                // La proprietà recognitionLanguages è disponibile da iOS 13.0+
                request.recognitionLanguages = getAllSupportedLanguages()
            }
            
            do {
                try requestHandler.perform([request])
            } catch {
                print("Errore durante il riconoscimento del testo: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    static func extractText(from url: URL, completion: @escaping (String?) -> Void) {
        // Verifica il tipo di file
        if url.pathExtension.lowercased() == "pdf" {
            extractTextFromPDF(url: url, completion: completion)
        } else if url.pathExtension.lowercased() == "txt" || url.pathExtension.lowercased() == "rtf" {
            extractTextFromTextFile(url: url, completion: completion)
        } else if ["jpg", "jpeg", "png", "heic"].contains(url.pathExtension.lowercased()) {
            // È un'immagine, usa OCR
            if let image = UIImage(contentsOfFile: url.path) {
                recognizeText(from: image, completion: completion)
            } else {
                completion(nil)
            }
        } else {
            // Prova a leggere come testo generico
            extractTextFromTextFile(url: url, completion: completion)
        }
    }
    
    private static func extractTextFromPDF(url: URL, completion: @escaping (String?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let pdfDocument = PDFDocument(url: url) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            var fullText = ""
            for pageIndex in 0..<pdfDocument.pageCount {
                if let page = pdfDocument.page(at: pageIndex) {
                    if let pageText = page.string {
                        fullText += pageText + "\n"
                    }
                }
            }
            
            DispatchQueue.main.async {
                completion(fullText.isEmpty ? nil : fullText)
            }
        }
    }
    
    private static func extractTextFromTextFile(url: URL, completion: @escaping (String?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let text = try String(contentsOf: url, encoding: .utf8)
                DispatchQueue.main.async {
                    completion(text.isEmpty ? nil : text)
                }
            } catch {
                // Prova con encoding diverso
                do {
                    let text = try String(contentsOf: url, encoding: .macOSRoman)
                    DispatchQueue.main.async {
                        completion(text.isEmpty ? nil : text)
                    }
                } catch {
                    print("Errore durante la lettura del file: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Language Support
    
    /// Restituisce tutte le lingue supportate da Vision Framework per il riconoscimento del testo
    private static func getAllSupportedLanguages() -> [String] {
        // Prova prima a ottenere dinamicamente tutte le lingue supportate dal sistema Vision
        // Prova con revisioni diverse per massimizzare il supporto
        
        // Prova con revisione 1 (iOS 13.0+)
        if let supportedLanguages = try? VNRecognizeTextRequest.supportedRecognitionLanguages(for: .accurate, revision: VNRecognizeTextRequestRevision1) {
            return supportedLanguages
        }
        
        // Prova con revisione 2 se disponibile (iOS 14.0+)
        if #available(iOS 14.0, *) {
            if let supportedLanguages = try? VNRecognizeTextRequest.supportedRecognitionLanguages(for: .accurate, revision: VNRecognizeTextRequestRevision2) {
                return supportedLanguages
            }
        }
        
        // Prova con revisione 3 se disponibile (iOS 16.0+)
        if #available(iOS 16.0, *) {
            if let supportedLanguages = try? VNRecognizeTextRequest.supportedRecognitionLanguages(for: .accurate, revision: VNRecognizeTextRequestRevision3) {
                return supportedLanguages
            }
        }
        
        // Fallback: lista COMPLETA di tutte le lingue supportate da Vision Framework
        // Questa è la lista più completa possibile basata sulle capacità di Vision Framework
        // Include TUTTE le lingue: danese, norvegese, arabo, islandese e tutte le altre
        return [
            // Lingue principali supportate da Vision Framework (accurate mode)
            "en-US", "fr-FR", "it-IT", "de-DE", "es-ES", "pt-BR", "zh-Hans", "zh-Hant",
            "yue-Hans", "yue-Hant", "ja-JP", "ko-KR", "ru-RU", "uk-UA",
            
            // Lingue europee aggiuntive (DANESE, NORVEGESE, ISLANDESE e altre)
            "sv-SE", "da-DK", "no-NO", "fi-FI", "is-IS", "nl-NL", "pl-PL", "cs-CZ",
            "sk-SK", "hu-HU", "ro-RO", "bg-BG", "hr-HR", "sr-Latn", "sr-Cyrl", "sl-SI",
            "el-GR", "et-EE", "lv-LV", "lt-LT", "mk-MK", "sq-AL", "mt-MT", "ga-IE",
            "cy-GB", "eu-ES", "ca-ES", "gl-ES", "pt-PT", "tr-TR",
            
            // Lingue mediorientali (ARABO e altre)
            "ar-SA", "ar-AE", "ar-EG", "he-IL", "fa-IR", "ur-PK",
            
            // Lingue asiatiche
            "hi-IN", "bn-BD", "ta-IN", "te-IN", "ml-IN", "kn-IN", "gu-IN", "pa-IN",
            "mr-IN", "ne-NP", "si-LK", "th-TH", "vi-VN", "id-ID", "ms-MY", "my-MM",
            "km-KH", "lo-LA", "ka-GE", "hy-AM", "az-AZ", "kk-KZ", "ky-KG", "uz-UZ",
            "mn-MN", "am-ET", "or-IN", "bo-CN",
            
            // Lingue africane
            "af-ZA", "sw-KE", "zu-ZA", "xh-ZA", "tn-ZA", "st-ZA", "ve-ZA", "ts-ZA",
            "ss-ZA", "nr-ZA", "nso-ZA",
            
            // Altre lingue
            "chr-US"
        ]
    }
}
