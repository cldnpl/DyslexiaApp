//
//  readingView.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 15/01/26.
//

import SwiftUI
import AVFoundation
import Combine
struct ReadingView: View {
    @Binding var isPresented: Bool
    @Binding var selectedTab: Int
    @State var textToRead: String
    @StateObject private var speechSynthesizer = SpeechSynthesizer()
    @State private var readingSpeed: Double = 0.5
    @State private var highlightedText: AttributedString = AttributedString()
    @Environment(\.dismiss) private var dismiss
    
    // Converti readingSpeed (0.0-1.0) a AVSpeechUtterance rate (0.0-1.0)
    private var speechRate: Float {
        return Float(0.3 + (readingSpeed * 0.3))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Slider per la velocità
            HStack(spacing: 15) {
                Image(systemName: "tortoise.fill")
                    .foregroundColor(Color(red: 182/255, green: 212/255, blue: 177/255))
                    .font(.title2)
                
                Slider(value: $readingSpeed, in: 0.0...1.0)
                    .tint(Color(red: 182/255, green: 212/255, blue: 177/255))
                    .onChange(of: readingSpeed) { newValue in
                        if speechSynthesizer.isPlaying {
                            let wasPlaying = speechSynthesizer.isPlaying
                            let currentIndex = speechSynthesizer.currentWordIndex
                            speechSynthesizer.stop()
                            if wasPlaying && currentIndex < speechSynthesizer.words.count {
                                let remainingWords = Array(speechSynthesizer.words[currentIndex...])
                                let remainingText = remainingWords.joined(separator: " ")
                                speechSynthesizer.speak(text: remainingText, rate: speechRate)
                            }
                        }
                    }
                
                Image(systemName: "hare.fill")
                    .foregroundColor(Color(red: 182/255, green: 212/255, blue: 177/255))
                    .font(.title2)
            }
            .shadow(radius: 10)
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            Spacer()
            
            // Card con il testo - grande come in insertManuallyView
            ZStack(alignment: .topLeading) {
                // Background con bordo come in insertManuallyView
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 182/255, green: 212/255, blue: 177/255))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .frame(maxWidth: 350)
                
                // Testo con evidenziazione e tap gesture
                ScrollView {
                    TextTapView(
                        text: textToRead,
                        highlightedText: highlightedText,
                        onTap: { wordIndex in
                            handleTextTap(wordIndex: wordIndex)
                        }
                    )
                }
                .frame(maxWidth: 350)
            }
            
            
            Spacer()
            
            // Controlli di riproduzione
            HStack(spacing: 40) {
                // Pulsante Bookmark
                Button(action: {
                    // TODO: Implementare salvataggio bookmark
                }) {
                    Image(systemName: "bookmark.fill")
                        .font(.title2)
                        .foregroundColor(.black)
                        .frame(width: 50, height: 50)
                        .background(Color(red: 182/255, green: 212/255, blue: 177/255))
                        .clipShape(Circle())
                }
                
                // Pulsante Play/Pause
                Button(action: {
                    if speechSynthesizer.isPlaying {
                        speechSynthesizer.pause()
                    } else if speechSynthesizer.isPaused {
                        speechSynthesizer.resume()
                    } else {
                        speechSynthesizer.setupText(textToRead)
                        speechSynthesizer.speak(text: textToRead, rate: speechRate)
                    }
                }) {
                    Image(systemName: speechSynthesizer.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                        .foregroundColor(.black)
                        .frame(width: 70, height: 70)
                        .background(Color(red: 182/255, green: 212/255, blue: 177/255))
                        .clipShape(Circle())
                }
                
                // Pulsante Ricomincia da capo
                Button(action: {
                    speechSynthesizer.stop()
                    speechSynthesizer.setupText(textToRead)
                    speechSynthesizer.speak(text: textToRead, rate: speechRate)
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                        .foregroundColor(.black)
                        .frame(width: 50, height: 50)
                        .background(Color(red: 182/255, green: 212/255, blue: 177/255))
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 40)
        }
        .background(Color(red: 65/255, green: 112/255, blue: 72/255))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    speechSynthesizer.stop()
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            // Inizializza highlightedText con il testo normale
            highlightedText = AttributedString(textToRead)
            updateHighlightedText()
            speechSynthesizer.onWordChanged = { index in
                updateHighlightedText()
            }
            speechSynthesizer.onPlaybackStateChanged = { _ in
                // UI aggiornata automaticamente tramite @Published
            }
        }
        .onDisappear {
            speechSynthesizer.stop()
        }
    }
    
    private func updateHighlightedText() {
        // Ricrea sempre l'AttributedString dal testo originale
        var attributedString = AttributedString(textToRead)
        
        // Evidenzia la parola corrente usando i range originali
        if !speechSynthesizer.originalWordRanges.isEmpty &&
            speechSynthesizer.currentWordIndex < speechSynthesizer.originalWordRanges.count {
            let currentRange = speechSynthesizer.originalWordRanges[speechSynthesizer.currentWordIndex]
            if let swiftRange = Range(currentRange, in: textToRead) {
                if let lowerBound = AttributedString.Index(swiftRange.lowerBound, within: attributedString),
                   let upperBound = AttributedString.Index(swiftRange.upperBound, within: attributedString) {
                    let wordRange = lowerBound..<upperBound
                    attributedString[wordRange].backgroundColor = .yellow
                    attributedString[wordRange].foregroundColor = .black
                }
            }
        }
        
        highlightedText = attributedString
    }
    
    private func handleTextTap(wordIndex: Int) {
        let wasPlaying = speechSynthesizer.isPlaying || speechSynthesizer.isPaused
        speechSynthesizer.jumpToWordFromOriginal(at: wordIndex, originalText: textToRead)
        
        // Se stava leggendo, riprendi dalla nuova posizione
        if wasPlaying {
            // Ricrea il testo dalla parola toccata in poi
            let allWords = textToRead.components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
                .filter { !$0.isEmpty && $0.trimmingCharacters(in: .whitespaces).count > 0 }
            
            if wordIndex < allWords.count {
                let remainingWords = Array(allWords[wordIndex...])
                let remainingText = remainingWords.joined(separator: " ")
                speechSynthesizer.speak(text: remainingText, rate: speechRate)
            }
        }
        
        updateHighlightedText()
    }
}

#Preview {
    ReadingView(
        isPresented: .constant(true),
        selectedTab: .constant(0),
        textToRead: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec magna metus, porta quis ex non, elementum rutrum turpis. Etiam volutpat eu sapien eleifend rhoncus. Donec vitae feugiat turpis. Donec volutpat purus leo, ut aliquet purus mollis vel. Nunc vitae bibendum sem, ut tristique orci. Maecenas nec urna rutrum eros venenatis placerat a id sapien. Etiam mattis lorem sit amet ipsum dapibus, vulputate viverra nulla cursus. Etiam dignissim, nibh vitae mollis sodales, orci tortor placerat nibh. vitae convallis elit nunc non"
    )
}
