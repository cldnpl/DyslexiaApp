//
//  Font+Dyslexia.swift
//  DyslexiaReader
//

import SwiftUI

extension Font {
    /// Restituisce il font corretto in base alle impostazioni: OpenDyslexic se dyslexiaFont è attivo, altrimenti system.
    static func app(size: CGFloat, weight: Font.Weight = .regular, dyslexia: Bool) -> Font {
        guard dyslexia else {
            return .system(size: size, weight: weight)
        }
        let name = weight == .bold ? "OpenDyslexic-Bold" : "OpenDyslexic-Regular"
        return .custom(name, size: size)
    }
}
