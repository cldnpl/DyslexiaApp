//
//  AppSettings.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 21/01/26.
//

import Foundation
import SwiftUI
import Combine

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    @Published var dyslexiaFont: Bool {
        didSet {
            UserDefaults.standard.set(dyslexiaFont, forKey: "dyslexiaFont")
        }
    }
    
    @Published var textSize: CGFloat {
        didSet {
            UserDefaults.standard.set(textSize, forKey: "textSize")
        }
    }
    
    @Published var voiceOverEnabled: Bool {
        didSet {
            UserDefaults.standard.set(voiceOverEnabled, forKey: "voiceOverEnabled")
        }
    }
    
    @Published var boldText: Bool {
        didSet {
            UserDefaults.standard.set(boldText, forKey: "boldText")
        }
    }
    
    @Published var colorContrast: Bool {
        didSet {
            UserDefaults.standard.set(colorContrast, forKey: "colorContrast")
        }
    }
    
    private init() {
        // Carica isDarkMode da UserDefaults, se non esiste usa false (default)
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        // Carica dyslexiaFont da UserDefaults, se non esiste usa false (default)
        self.dyslexiaFont = UserDefaults.standard.bool(forKey: "dyslexiaFont")
        
        // Carica textSize da UserDefaults, se non esiste usa 16.0 (default)
        self.textSize = UserDefaults.standard.object(forKey: "textSize") as? CGFloat ?? 16.0
        
        // Carica voiceOverEnabled da UserDefaults, se non esiste usa false (default)
        self.voiceOverEnabled = UserDefaults.standard.bool(forKey: "voiceOverEnabled")
        
        // Carica boldText da UserDefaults, se non esiste usa false (default)
        self.boldText = UserDefaults.standard.bool(forKey: "boldText")
        
        // Carica colorContrast da UserDefaults, se non esiste usa false (default)
        self.colorContrast = UserDefaults.standard.bool(forKey: "colorContrast")
    }
}
