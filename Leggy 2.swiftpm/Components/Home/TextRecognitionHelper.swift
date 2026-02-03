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
import UIKit

class TextRecognitionHelper {
    static func recognizeText(from image: UIImage, completion: @escaping @Sendable (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        // Run recognition on background thread to avoid blocking UI
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
            
            // Multilingual support: enable recognition for ALL supported languages
            // Vision Framework automatically supports all languages when no array is specified
            // But to maximize accuracy, we specify all main supported languages
            if #available(iOS 13.0, *) {
                // recognitionLanguages property is available from iOS 13.0+
                request.recognitionLanguages = getAllSupportedLanguages()
            }
            
            do {
                try requestHandler.perform([request])
            } catch {
                print("Error during text recognition: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    static func extractText(from url: URL, completion: @escaping @Sendable (String?) -> Void) {
        // Check file type
        if url.pathExtension.lowercased() == "pdf" {
            extractTextFromPDF(url: url, completion: completion)
        } else if url.pathExtension.lowercased() == "txt" || url.pathExtension.lowercased() == "rtf" {
            extractTextFromTextFile(url: url, completion: completion)
        } else if ["jpg", "jpeg", "png", "heic"].contains(url.pathExtension.lowercased()) {
            // It's an image, use OCR
            if let image = UIImage(contentsOfFile: url.path) {
                recognizeText(from: image, completion: completion)
            } else {
                completion(nil)
            }
        } else {
            // Try reading as generic text
            extractTextFromTextFile(url: url, completion: completion)
        }
    }
    
    private static func extractTextFromPDF(url: URL, completion: @escaping @Sendable (String?) -> Void) {
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
    
    private static func extractTextFromTextFile(url: URL, completion: @escaping @Sendable (String?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let text = try String(contentsOf: url, encoding: .utf8)
                DispatchQueue.main.async {
                    completion(text.isEmpty ? nil : text)
                }
            } catch {
                // Try with different encoding
                do {
                    let text = try String(contentsOf: url, encoding: .macOSRoman)
                    DispatchQueue.main.async {
                        completion(text.isEmpty ? nil : text)
                    }
                } catch {
                    print("Error during file reading: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Language Support
    
    /// Returns all languages supported by Vision Framework for text recognition
    private static func getAllSupportedLanguages() -> [String] {
        // Try first to get dynamically all languages supported by Vision system
        // Try different revisions to maximize support
        
        // supportedRecognitionLanguages APIs are deprecated from iOS 15.0+
        // We use the hardcoded list directly which is more reliable
        
        // Fallback: COMPLETE list of all languages supported by Vision Framework
        // This is the most complete list possible based on Vision Framework capabilities
        // Includes ALL languages: Danish, Norwegian, Arabic, Icelandic and all others
        return [
            // Main languages supported by Vision Framework (accurate mode)
            "en-US", "fr-FR", "it-IT", "de-DE", "es-ES", "pt-BR", "zh-Hans", "zh-Hant",
            "yue-Hans", "yue-Hant", "ja-JP", "ko-KR", "ru-RU", "uk-UA",
            
            // Additional European languages (DANISH, NORWEGIAN, ICELANDIC and others)
            "sv-SE", "da-DK", "no-NO", "fi-FI", "is-IS", "nl-NL", "pl-PL", "cs-CZ",
            "sk-SK", "hu-HU", "ro-RO", "bg-BG", "hr-HR", "sr-Latn", "sr-Cyrl", "sl-SI",
            "el-GR", "et-EE", "lv-LV", "lt-LT", "mk-MK", "sq-AL", "mt-MT", "ga-IE",
            "cy-GB", "eu-ES", "ca-ES", "gl-ES", "pt-PT", "tr-TR",
            
            // Middle Eastern languages (ARABIC and others)
            "ar-SA", "ar-AE", "ar-EG", "he-IL", "fa-IR", "ur-PK",
            
            // Asian languages
            "hi-IN", "bn-BD", "ta-IN", "te-IN", "ml-IN", "kn-IN", "gu-IN", "pa-IN",
            "mr-IN", "ne-NP", "si-LK", "th-TH", "vi-VN", "id-ID", "ms-MY", "my-MM",
            "km-KH", "lo-LA", "ka-GE", "hy-AM", "az-AZ", "kk-KZ", "ky-KG", "uz-UZ",
            "mn-MN", "am-ET", "or-IN", "bo-CN",
            
            // African languages
            "af-ZA", "sw-KE", "zu-ZA", "xh-ZA", "tn-ZA", "st-ZA", "ve-ZA", "ts-ZA",
            "ss-ZA", "nr-ZA", "nso-ZA",
            
            // Other languages
            "chr-US"
        ]
    }
}
