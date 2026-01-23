//
//  Font+Dyslexia.swift
//  DyslexiaReader
//

import SwiftUI

extension Font {
    static func app(size: CGFloat, weight: Font.Weight = .regular, dyslexia: Bool) -> Font {
        let settings = AppSettings.shared
        return app(size: size, weight: weight, font: settings.selectedFont)
    }
    
    static func app(size: CGFloat, weight: Font.Weight = .regular, font: AppFont) -> Font {
        guard let fontName = weight == .bold ? font.boldFontName : font.fontName else {
            return .system(size: size, weight: weight)
        }
        
        // Per OpenDyslexic, prova diversi nomi possibili
        if font == .openDyslexic {
            let possibleNames: [String]
            if weight == .bold {
                possibleNames = [
                    "OpenDyslexic-Bold",
                    "OpenDyslexic Bold",
                    "OpenDyslexicBold",
                    "OpenDyslexic"
                ]
            } else {
                possibleNames = [
                    "OpenDyslexic-Regular",
                    "OpenDyslexic Regular",
                    "OpenDyslexicRegular",
                    "OpenDyslexic"
                ]
            }
            
            print("🔍 Tentativo di caricare OpenDyslexic (weight: \(weight == .bold ? "bold" : "regular"))...")
            for name in possibleNames {
                if let customFont = UIFont(name: name, size: size) {
                    print("✅ SUCCESSO! Font trovato con nome: '\(name)'")
                    return Font(customFont)
                } else {
                    print("   ❌ Tentativo fallito: '\(name)'")
                }
            }
            
            print("⚠️ Font OpenDyslexic non trovato con nessun nome provato!")
            print("🔍 Cercando in tutte le famiglie di font...")
            var foundAny = false
            UIFont.familyNames.forEach { family in
                let fonts = UIFont.fontNames(forFamilyName: family)
                if fonts.contains(where: { $0.localizedCaseInsensitiveContains("dyslexic") || $0.localizedCaseInsensitiveContains("open") }) {
                    foundAny = true
                    print("   📁 Famiglia trovata: \(family)")
                    fonts.forEach { fontName in
                        print("      📝 Nome: '\(fontName)'")
                    }
                }
            }
            if !foundAny {
                print("   ❌ Nessun font OpenDyslexic trovato nel sistema!")
            }
        } else {
            // Prova a usare il font custom
            if let customFont = UIFont(name: fontName, size: size) {
                return Font(customFont)
            }
        }
        
        // Per i font di sistema, prova con il nome display
        if font != .system, let systemFont = UIFont(name: font.displayName, size: size) {
            return Font(systemFont)
        }
        
        // Fallback al font di sistema
        print("⚠️ Usando font di sistema come fallback per: \(font.displayName)")
        return .system(size: size, weight: weight)
    }
}
