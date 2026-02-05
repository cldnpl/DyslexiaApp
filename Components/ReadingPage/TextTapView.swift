//
//  TextTapView.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 15/01/26.
//

import SwiftUI
import UIKit

// Vista nativa SwiftUI per gestire il tap preciso sul testo
struct TextTapView: View {
    let text: String
    let highlightedText: AttributedString
    let onTap: (Int) -> Void
    @StateObject private var settings = AppSettings.shared
    
    var body: some View {
        Text(highlightedText)
            .font(settings.customFont(size: settings.textSize, weight: settings.boldText ? .bold : .regular))
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(10)
            .overlay(
                GeometryReader { geometry in
                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { value in
                                    handleTap(at: value.location, in: geometry.size)
                                }
                        )
                }
            )
    }
    
    private func handleTap(at location: CGPoint, in size: CGSize) {
        // Dividi il testo in parole
        let words = text.components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            .filter { !$0.isEmpty && $0.trimmingCharacters(in: .whitespaces).count > 0 }
        
        // Crea un'attributed string per calcolare le posizioni
        let attributedString = NSMutableAttributedString(highlightedText)
        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: size)
        
        textContainer.lineFragmentPadding = 0
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        // Forza il layout
        layoutManager.ensureLayout(for: textContainer)
        
        // Trova il carattere alla posizione del tap
        let characterIndex = layoutManager.characterIndex(
            for: location,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        guard characterIndex < text.count else { return }
        
        // Trova quale parola contiene questo carattere
        var currentLocation = 0
        let nsString = text as NSString
        
        for (index, word) in words.enumerated() {
            let searchRange = NSRange(location: currentLocation, length: nsString.length - currentLocation)
            let range = nsString.range(of: word, options: [], range: searchRange)
            if range.location != NSNotFound {
                if characterIndex >= range.location && characterIndex < range.location + range.length {
                    onTap(index)
                    return
                }
                currentLocation = range.location + range.length
            }
        }
    }
}
