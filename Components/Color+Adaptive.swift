//
//  Color+Adaptive.swift
//  DyslexiaReader
//

import SwiftUI

extension Color {
    // Colore adattivo per icone e bottoni: blu in light mode, primary/bianco in dark mode
    static var adaptiveIcon: Color {
        let settings = AppSettings.shared
        return settings.isDarkMode ? .primary : .blue
    }
    
    // Colore adattivo per accenti: blu in light mode, bianco in dark mode
    static var adaptiveAccent: Color {
        let settings = AppSettings.shared
        return settings.isDarkMode ? .white : .blue
    }
}
