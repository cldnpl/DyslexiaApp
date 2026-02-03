import SwiftUI
import CoreText

@main
struct DyslexiaReaderApp: App {
    @ObservedObject private var settings = AppSettings.shared
    
    init() {
        loadCustomFonts()
    }
    
    private func loadCustomFonts() {
        let fontNames = [
            "OpenDyslexic-Regular",
            "OpenDyslexic-Bold",
            "OpenDyslexic-Italic",
            "OpenDyslexic-BoldItalic"
        ]
        
        for fontName in fontNames {
            guard let fontURL = Bundle.main.url(forResource: fontName, withExtension: "otf") else {
                continue
            }
            
            var error: Unmanaged<CFError>?
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Non forziamo il color scheme, lasciamo che segua quello del sistema
        }
    }
}
