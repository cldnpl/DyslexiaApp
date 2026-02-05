//
//  AppSettings.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 21/01/26.
//

import Foundation
import SwiftUI
import UIKit
import Combine

class AppSettings: ObservableObject, @unchecked Sendable {
    static let shared = AppSettings()
    
    // Computed property that reads system color scheme
    private static let accentColorKeyRed = "accentColorRedV2"
    private static let accentColorKeyGreen = "accentColorGreenV2"
    private static let accentColorKeyBlue = "accentColorBlueV2"
    private static let accentColorKeyAlpha = "accentColorAlphaV2"
    
    private static let textColorKeyRed = "textColorRed"
    private static let textColorKeyGreen = "textColorGreen"
    private static let textColorKeyBlue = "textColorBlue"
    private static let textColorKeyAlpha = "textColorAlpha"
    private static let textColorKeyIsSystem = "textColorIsSystem"
    
    private static let textFieldBackgroundColorKeyRed = "textFieldBackgroundColorRed"
    private static let textFieldBackgroundColorKeyGreen = "textFieldBackgroundColorGreen"
    private static let textFieldBackgroundColorKeyBlue = "textFieldBackgroundColorBlue"
    private static let textFieldBackgroundColorKeyAlpha = "textFieldBackgroundColorAlpha"
    private static let textFieldBackgroundColorKeyIsSystem = "textFieldBackgroundColorIsSystem"
    
    @Published var accentColor: Color {
        didSet {
            let uiColor = UIColor(accentColor)
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            UserDefaults.standard.set(red, forKey: Self.accentColorKeyRed)
            UserDefaults.standard.set(green, forKey: Self.accentColorKeyGreen)
            UserDefaults.standard.set(blue, forKey: Self.accentColorKeyBlue)
            UserDefaults.standard.set(alpha, forKey: Self.accentColorKeyAlpha)
            
            objectWillChange.send()
        }
    }
    
    @Published var textColor: Color {
        didSet {
            // Always save the color RGB values
            let uiColor = UIColor(textColor)
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            
            // Try to get RGB values, if it fails (e.g., semantic colors), use default primary
            if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
                UserDefaults.standard.set(false, forKey: Self.textColorKeyIsSystem)
                UserDefaults.standard.set(red, forKey: Self.textColorKeyRed)
                UserDefaults.standard.set(green, forKey: Self.textColorKeyGreen)
                UserDefaults.standard.set(blue, forKey: Self.textColorKeyBlue)
                UserDefaults.standard.set(alpha, forKey: Self.textColorKeyAlpha)
            } else {
                // If it's a semantic color like .primary, mark as system
                UserDefaults.standard.set(true, forKey: Self.textColorKeyIsSystem)
            }
            
            objectWillChange.send()
        }
    }
    
    @Published var textFieldBackgroundColor: Color {
        didSet {
            // Always save the color RGB values
            let uiColor = UIColor(textFieldBackgroundColor)
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            
            // Try to get RGB values, if it fails (e.g., semantic colors), use default systemGroupedBackground
            if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
                UserDefaults.standard.set(false, forKey: Self.textFieldBackgroundColorKeyIsSystem)
                UserDefaults.standard.set(red, forKey: Self.textFieldBackgroundColorKeyRed)
                UserDefaults.standard.set(green, forKey: Self.textFieldBackgroundColorKeyGreen)
                UserDefaults.standard.set(blue, forKey: Self.textFieldBackgroundColorKeyBlue)
                UserDefaults.standard.set(alpha, forKey: Self.textFieldBackgroundColorKeyAlpha)
                
                // Calcola automaticamente il colore del testo in base al contrasto
                let backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                let optimalTextColor = Self.calculateOptimalTextColor(for: backgroundColor)
                self.textColor = Color(optimalTextColor)
            } else {
                // If it's a semantic color, mark as system
                UserDefaults.standard.set(true, forKey: Self.textFieldBackgroundColorKeyIsSystem)
            }
            
            objectWillChange.send()
        }
    }
    
    @MainActor
    var isDarkMode: Bool {
        // Use main window trait collection if available
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return window.traitCollection.userInterfaceStyle == .dark
        }
        // Last fallback: check current trait collection
        return UITraitCollection.current.userInterfaceStyle == .dark
    }
    
    // Helper to update UI when color scheme changes
    func updateForColorSchemeChange() {
        objectWillChange.send()
    }
    
    @Published var selectedFont: String {
        didSet {
            UserDefaults.standard.set(selectedFont, forKey: "selectedFont")
        }
    }
    
    // Kept for backward compatibility
    var dyslexiaFont: Bool {
        get {
            return selectedFont != "System"
        }
        set {
            selectedFont = newValue ? "OpenDyslexic" : "System"
        }
    }
    
    static let availableFonts = [
        "System",
        "OpenDyslexic",
        "OpenDyslexic Italic",
        "Helvetica Neue",
        "Arial",
        "Times New Roman",
        "Courier New",
        "Georgia",
        "Trebuchet MS",
        "Verdana"
    ]
    
    @Published var textSize: CGFloat {
        didSet {
            UserDefaults.standard.set(textSize, forKey: "textSize")
            objectWillChange.send()
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
            objectWillChange.send()
        }
    }
    
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
            objectWillChange.send()
        }
    }
    
    // Computed properties that respect system accessibility settings
    var dynamicTextSize: CGFloat {
        let systemBodySize = UIFont.preferredFont(forTextStyle: .body).pointSize
        // Scale relative to system base size (17.0 is iOS default)
        let systemBaseSize: CGFloat = 17.0
        let scaleFactor = textSize / systemBaseSize
        return systemBodySize * scaleFactor
    }
    
    @MainActor
    var shouldUseBoldText: Bool {
        return boldText || UIAccessibility.isBoldTextEnabled
    }
    
    private var accessibilityObserver: NSObjectProtocol?
    private var traitCollectionObserver: NSObjectProtocol?
    
    private init() {
        // Load accentColor from UserDefaults, if missing use blue (default)
        if UserDefaults.standard.object(forKey: Self.accentColorKeyRed) != nil {
            let red = UserDefaults.standard.double(forKey: Self.accentColorKeyRed)
            let green = UserDefaults.standard.double(forKey: Self.accentColorKeyGreen)
            let blue = UserDefaults.standard.double(forKey: Self.accentColorKeyBlue)
            let alpha = UserDefaults.standard.double(forKey: Self.accentColorKeyAlpha)
            self.accentColor = Color(red: red, green: green, blue: blue, opacity: alpha)
        } else {
            self.accentColor = .blue
        }
        
        // Load selectedFont from UserDefaults, with backward compatibility fallback
        if let fontString = UserDefaults.standard.string(forKey: "selectedFont"),
           Self.availableFonts.contains(fontString) {
            self.selectedFont = fontString
        } else {
            // Backward compatibility: if old dyslexiaFont value exists
            let oldDyslexiaFont = UserDefaults.standard.bool(forKey: "dyslexiaFont")
            self.selectedFont = oldDyslexiaFont ? "OpenDyslexic" : "System"
        }
        
        // Load textSize from UserDefaults, if missing use 17.0 (default)
        self.textSize = UserDefaults.standard.object(forKey: "textSize") as? CGFloat ?? 17.0
        
        // Load voiceOverEnabled from UserDefaults, if missing use false (default)
        self.voiceOverEnabled = UserDefaults.standard.bool(forKey: "voiceOverEnabled")
        
        // Load boldText from UserDefaults, if missing use false (default)
        self.boldText = UserDefaults.standard.bool(forKey: "boldText")
        
        // Load hasCompletedOnboarding from UserDefaults, if missing use false (default)
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        // Load textColor from UserDefaults, if missing use primary (default)
        let isSystemColor = UserDefaults.standard.bool(forKey: Self.textColorKeyIsSystem)
        if isSystemColor {
            self.textColor = .primary
        } else if UserDefaults.standard.object(forKey: Self.textColorKeyRed) != nil {
            let red = UserDefaults.standard.double(forKey: Self.textColorKeyRed)
            let green = UserDefaults.standard.double(forKey: Self.textColorKeyGreen)
            let blue = UserDefaults.standard.double(forKey: Self.textColorKeyBlue)
            let alpha = UserDefaults.standard.double(forKey: Self.textColorKeyAlpha)
            self.textColor = Color(red: red, green: green, blue: blue, opacity: alpha)
        } else {
            self.textColor = .primary
        }
        
        // Load textFieldBackgroundColor from UserDefaults, if missing use systemGroupedBackground (default)
        let isSystemBackgroundColor = UserDefaults.standard.bool(forKey: Self.textFieldBackgroundColorKeyIsSystem)
        if isSystemBackgroundColor {
            self.textFieldBackgroundColor = Color(uiColor: .systemGroupedBackground)
        } else if UserDefaults.standard.object(forKey: Self.textFieldBackgroundColorKeyRed) != nil {
            let red = UserDefaults.standard.double(forKey: Self.textFieldBackgroundColorKeyRed)
            let green = UserDefaults.standard.double(forKey: Self.textFieldBackgroundColorKeyGreen)
            let blue = UserDefaults.standard.double(forKey: Self.textFieldBackgroundColorKeyBlue)
            let alpha = UserDefaults.standard.double(forKey: Self.textFieldBackgroundColorKeyAlpha)
            self.textFieldBackgroundColor = Color(red: red, green: green, blue: blue, opacity: alpha)
        } else {
            self.textFieldBackgroundColor = Color(uiColor: .systemGroupedBackground)
        }
        
        // Listen for accessibility settings changes
        setupAccessibilityObserver()
        
        // Listen for system color scheme changes
        setupTraitCollectionObserver()
    }
    
    private func setupAccessibilityObserver() {
        // Listen for accessibility settings changes
        accessibilityObserver = NotificationCenter.default.addObserver(
            forName: UIContentSizeCategory.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.objectWillChange.send()
        }
        
        // Also listen for bold text changes
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.boldTextStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
    
    private func setupTraitCollectionObserver() {
        // Listen for trait collection (color scheme) changes
        // When app becomes active, check if color scheme changed
        traitCollectionObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateForColorSchemeChange()
        }
        
        // Also listen when app enters foreground
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateForColorSchemeChange()
        }
    }
    
    deinit {
        if let observer = accessibilityObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = traitCollectionObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // Funzione helper per ottenere il nome del font corretto da usare con Font.custom()
    func fontName(for weight: Font.Weight = .regular) -> String {
        return Self.fontName(for: weight, fontName: selectedFont)
    }
    
    // Funzione helper statica per ottenere il nome del font corretto da una stringa
    static func fontName(for weight: Font.Weight = .regular, fontName: String) -> String {
        if fontName == "System" {
            return "System"
        }
        
        // For OpenDyslexic, look up actual font name in system
        if fontName == "OpenDyslexic" || fontName == "OpenDyslexic Italic" {
            return findOpenDyslexicFontName(baseName: fontName, weight: weight)
        } else {
            // For other fonts, use name directly
            return fontName
        }
    }
    
    // Helper to find actual OpenDyslexic font name in system
    static func findOpenDyslexicFontName(baseName: String, weight: Font.Weight) -> String {
        // Search in OpenDyslexic family
        for familyName in UIFont.familyNames {
            if familyName.contains("OpenDyslexic") || familyName.contains("Dyslexic") {
                let fontNames = UIFont.fontNames(forFamilyName: familyName)
                
                // Determine which variant to look for
                let isItalic = baseName.contains("Italic")
                let isBold = (weight == .bold || weight == .semibold || weight == .heavy || weight == .black)
                
                // Cerca il font corretto
                if isItalic && isBold {
                    // Look for BoldItalic
                    if let found = fontNames.first(where: { $0.contains("Bold") && $0.contains("Italic") }) {
                        return found
                    }
                } else if isItalic {
                    // Look for Italic
                    if let found = fontNames.first(where: { $0.contains("Italic") && !$0.contains("Bold") }) {
                        return found
                    }
                } else if isBold {
                    // Look for Bold
                    if let found = fontNames.first(where: { $0.contains("Bold") && !$0.contains("Italic") }) {
                        return found
                    }
                } else {
                    // Look for Regular
                    if let found = fontNames.first(where: { $0.contains("Regular") || (!$0.contains("Bold") && !$0.contains("Italic")) }) {
                        return found
                    }
                }
                
                // Fallback: use first available font
                if let firstFont = fontNames.first {
                    return firstFont
                }
            }
        }
        
        // Fallback to standard names if not found
        if baseName == "OpenDyslexic" {
            return (weight == .bold || weight == .semibold || weight == .heavy || weight == .black) 
                ? "OpenDyslexic-Bold" 
                : "OpenDyslexic-Regular"
        } else {
            return (weight == .bold || weight == .semibold || weight == .heavy || weight == .black) 
                ? "OpenDyslexic-BoldItalic" 
                : "OpenDyslexic-Italic"
        }
    }
    
    // Helper to get Font directly (like in Leap)
    // Now respects system accessibility settings
    @MainActor
    func customFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        // Calculate dynamic size based on requested size
        let systemBodySize = UIFont.preferredFont(forTextStyle: .body).pointSize
        let systemBaseSize: CGFloat = 17.0
        let scaleFactor = size / systemBaseSize
        let dynamicSize = systemBodySize * scaleFactor
        
        // Determine font weight considering accessibility settings
        var finalWeight = weight
        if shouldUseBoldText && weight == .regular {
            finalWeight = .bold
        } else if shouldUseBoldText && weight != .regular {
            // If already bold or other weight, keep it but ensure it's bold enough
            finalWeight = weight
        }
        
        if selectedFont == "System" {
            return .system(size: dynamicSize, weight: finalWeight)
        }
        let actualFontName = fontName(for: finalWeight)
        return Font.custom(actualFontName, size: dynamicSize).weight(finalWeight)
    }
    
    // Helper to list all available fonts (useful for debug)
    static func printAllAvailableFonts() {
        print("=== FONT DISPONIBILI NEL SISTEMA ===")
        for familyName in UIFont.familyNames.sorted() {
            if familyName.contains("OpenDyslexic") || familyName.contains("Dyslexic") {
                print("\n🎯 TROVATO: Famiglia: \(familyName)")
                for fontName in UIFont.fontNames(forFamilyName: familyName) {
                    print("  ✅ \(fontName)")
                }
            }
        }
        print("\n=== TUTTI I FONT ===")
        for familyName in UIFont.familyNames.sorted() {
            print("\nFamiglia: \(familyName)")
            for fontName in UIFont.fontNames(forFamilyName: familyName) {
                print("  - \(fontName)")
            }
        }
    }
    
    // Calcola la luminosità relativa di un colore (formula WCAG)
    private static func relativeLuminance(_ color: UIColor) -> CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            // Se non riesce a ottenere RGB, usa un valore di default
            return 0.5
        }
        
        // Converti i valori RGB in luminosità relativa (formula WCAG)
        func linearize(_ component: CGFloat) -> CGFloat {
            return component <= 0.03928
                ? component / 12.92
                : pow((component + 0.055) / 1.055, 2.4)
        }
        
        let r = linearize(red)
        let g = linearize(green)
        let b = linearize(blue)
        
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
    
    // Calcola il contrast ratio tra due colori (formula WCAG)
    private static func contrastRatio(_ color1: UIColor, _ color2: UIColor) -> CGFloat {
        let l1 = relativeLuminance(color1)
        let l2 = relativeLuminance(color2)
        
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    // Determina il colore del testo ottimale (bianco o nero) in base al contrasto
    static func calculateOptimalTextColor(for backgroundColor: UIColor) -> UIColor {
        let white = UIColor.white
        let black = UIColor.black
        
        let contrastWithWhite = contrastRatio(backgroundColor, white)
        let contrastWithBlack = contrastRatio(backgroundColor, black)
        
        // Usa il colore con contrasto più alto
        return contrastWithWhite > contrastWithBlack ? white : black
    }
}
