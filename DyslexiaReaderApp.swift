//
//  DyslexiaReaderApp.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 13/01/26.
//

import SwiftUI

@main
struct DyslexiaReaderApp: App {
    @StateObject private var settings = AppSettings.shared
    
    init() {
        // Debug completo: stampa TUTTI i font disponibili
        print("============================================================")
        print("🔍 DEBUG FONT - Verifica font OpenDyslexic")
        print("============================================================")
        
        var foundDyslexic = false
        
        UIFont.familyNames.sorted().forEach { family in
            let fonts = UIFont.fontNames(forFamilyName: family)
            let hasDyslexic = fonts.contains(where: { $0.localizedCaseInsensitiveContains("dyslexic") || $0.localizedCaseInsensitiveContains("open") })
            
            if hasDyslexic {
                foundDyslexic = true
                print("\n✅ TROVATO! Famiglia: \(family)")
                fonts.forEach { fontName in
                    print("    📝 Nome font: '\(fontName)'")
                }
            }
        }
        
        if !foundDyslexic {
            print("\n❌ ATTENZIONE: Nessun font OpenDyslexic trovato!")
            print("\n📋 Possibili problemi:")
            print("   1. I font non sono aggiunti al Target in Xcode")
            print("   2. I font non sono nel bundle dell'app")
            print("   3. Devi fare Clean Build e reinstallare l'app")
            print("\n📂 Font cercati:")
            print("   - OpenDyslexic-Regular")
            print("   - OpenDyslexic Regular")
            print("   - OpenDyslexicRegular")
            print("   - OpenDyslexic")
        }
        
        print("\n============================================================")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(settings.isDarkMode ? .dark : .light)
        }
    }
}
