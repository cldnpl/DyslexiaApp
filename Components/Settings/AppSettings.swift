//
//  AppSettings.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 21/01/26.
//

import Foundation
import SwiftUI
import Combine

enum AppFont: String, CaseIterable {
    case system = "System"
    case openDyslexic = "OpenDyslexic"
    case helveticaNeue = "Helvetica Neue"
    case arial = "Arial"
    case timesNewRoman = "Times New Roman"
    case courierNew = "Courier New"
    case georgia = "Georgia"
    case trebuchetMS = "Trebuchet MS"
    case verdana = "Verdana"
    
    var displayName: String {
        return self.rawValue
    }
    
    var fontName: String? {
        switch self {
        case .system:
            return nil
        case .openDyslexic:
            return "OpenDyslexic-Regular"
        default:
            return self.rawValue
        }
    }
    
    var boldFontName: String? {
        switch self {
        case .system:
            return nil
        case .openDyslexic:
            return "OpenDyslexic-Bold"
        default:
            return self.rawValue
        }
    }
    
    // Verifica se il font è disponibile nel sistema
    func isAvailable() -> Bool {
        if self == .system {
            return true
        }
        
        // Per OpenDyslexic, prova tutti i nomi possibili
        if self == .openDyslexic {
            let possibleNames = [
                "OpenDyslexic-Regular",
                "OpenDyslexic Regular",
                "OpenDyslexicRegular",
                "OpenDyslexic"
            ]
            return possibleNames.contains { UIFont(name: $0, size: 17) != nil }
        }
        
        // Per gli altri font, prova con fontName e rawValue
        if let fontName = self.fontName {
            if UIFont(name: fontName, size: 17) != nil {
                return true
            }
        }
        return UIFont(name: self.rawValue, size: 17) != nil
    }
}

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    @Published var selectedFont: AppFont {
        didSet {
            UserDefaults.standard.set(selectedFont.rawValue, forKey: "selectedFont")
        }
    }
    
    // Manteniamo per retrocompatibilità
    var dyslexiaFont: Bool {
        get {
            return selectedFont != .system
        }
        set {
            selectedFont = newValue ? .openDyslexic : .system
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
        
        // Carica selectedFont da UserDefaults, con fallback per retrocompatibilità
        if let fontString = UserDefaults.standard.string(forKey: "selectedFont"),
           let font = AppFont(rawValue: fontString) {
            self.selectedFont = font
        } else {
            // Retrocompatibilità: se esiste il vecchio valore dyslexiaFont
            let oldDyslexiaFont = UserDefaults.standard.bool(forKey: "dyslexiaFont")
            self.selectedFont = oldDyslexiaFont ? .openDyslexic : .system
        }
        
        // Carica textSize da UserDefaults, se non esiste usa 17.0 (default)
        self.textSize = UserDefaults.standard.object(forKey: "textSize") as? CGFloat ?? 17.0
        
        // Carica voiceOverEnabled da UserDefaults, se non esiste usa false (default)
        self.voiceOverEnabled = UserDefaults.standard.bool(forKey: "voiceOverEnabled")
        
        // Carica boldText da UserDefaults, se non esiste usa false (default)
        self.boldText = UserDefaults.standard.bool(forKey: "boldText")
        
        // Carica colorContrast da UserDefaults, se non esiste usa false (default)
        self.colorContrast = UserDefaults.standard.bool(forKey: "colorContrast")
    }
}
