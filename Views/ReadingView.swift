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
    @StateObject private var settings = AppSettings.shared
    @StateObject private var savedStore = SavedStore.shared
    @State private var readingSpeed: Double = 0.5
    @State private var highlightedText: AttributedString = AttributedString()
    @State private var showSaveModal = false
    @State private var saveTitle = ""
    @State private var showEditSheet = false
    @State private var editText = ""
    @Environment(\.dismiss) private var dismiss
    
    // Convert readingSpeed (0.0-1.0) to AVSpeechUtterance rate (0.0-1.0)
    private var speechRate: Float {
        return Float(0.05 + (readingSpeed * 0.8))
    }
    
    private var trimmedTextToRead: String {
        textToRead.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var isSaved: Bool {
        savedStore.items.contains { $0.fullText == trimmedTextToRead }
    }

    private var adaptiveTextFieldBackground: Color {
        settings.isDarkMode
            ? Color(uiColor: .secondarySystemGroupedBackground)
            : settings.textFieldBackgroundColor
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Speed slider with iOS Text Size–style container
            HStack(spacing: 16) {
                Image(systemName: "tortoise.fill")
                    .foregroundColor(settings.accentColor)
                    .font(.system(size: settings.textSize * 1.375))
                
                Slider(value: $readingSpeed, in: 0.0...1.0)
                    .tint(settings.accentColor)
                    .onChange(of: readingSpeed) { newValue in
                        // Change speed and resume from current position if playing
                        speechSynthesizer.changeSpeed(rate: speechRate)
                    }
                
                Image(systemName: "hare.fill")
                    .foregroundColor(settings.accentColor)
                    .font(.system(size: settings.textSize * 1.375))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(uiColor: .systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(uiColor: .separator).opacity(0.5), lineWidth: 0.5)
            )
            .padding(.horizontal, 30)
            .padding(.bottom, 16)
            .padding(.top, 24)

            Spacer()
                .frame(maxHeight: 2)
            
            // Card con il testo
            ZStack(alignment: .topLeading) {
                // Background che si adatta al light/dark mode e al colore personalizzato
                RoundedRectangle(cornerRadius: 12)
                    .fill(adaptiveTextFieldBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(uiColor: .separator), lineWidth: 1)
                    )
                    .frame(width: 340, height: 390)
                    .frame(minHeight: 200)
                
                // Testo con evidenziazione
                Group {
                    if #available(iOS 17.0, *) {
                        ScrollView {
                            Text(highlightedText)
                                .font(settings.customFont(size: settings.textSize, weight: settings.boldText ? .bold : .regular))
                                .foregroundColor(settings.textColor)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 2)
                        }
                        .scrollContentBackground(.hidden)
                        .contentMargins(.vertical, 0, for: .scrollIndicators)
                    } else {
                        ScrollView {
                            Text(highlightedText)
                                .font(settings.customFont(size: settings.textSize, weight: settings.boldText ? .bold : .regular))
                                .foregroundColor(settings.textColor)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 2)
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
                .frame(width: 340, height: 370)
                .frame(minHeight: 200)
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Controlli di riproduzione
            HStack(spacing: 40) {
                // Pulsante Bookmark
                Button(action: {
                    saveTitle = ""
                    showSaveModal = true
                }) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: settings.textSize * 1.375))
                        .foregroundColor(settings.accentColor)
                        .frame(width: 50, height: 50)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .disabled(isSaved)
                
                // Pulsante Play/Pause
                Button(action: {
                    if speechSynthesizer.isPlaying {
                        speechSynthesizer.pause()
                    } else if speechSynthesizer.isPaused {
                        speechSynthesizer.resume(rate: speechRate)
                    } else {
                        speechSynthesizer.setupText(textToRead)
                        speechSynthesizer.speak(text: textToRead, rate: speechRate)
                    }
                }) {
                    Image(systemName: speechSynthesizer.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: settings.textSize * 1.75))
                        .foregroundColor(settings.accentColor)
                        .frame(width: 70, height: 70)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(Circle())
                        .shadow(radius: 5)

                }
                
                // Pulsante Ricomincia da capo
                Button(action: {
                    speechSynthesizer.stop()
                    speechSynthesizer.setupText(textToRead)
                    updateHighlightedText()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: settings.textSize * 1.375))
                        .foregroundColor(settings.accentColor)
                        .frame(width: 50, height: 50)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(Circle())
                        .shadow(radius: 5)

                }
            }
            .padding(.bottom, 40)
        }
        .background(Color(uiColor: .systemBackground))
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
                        .foregroundColor(.primary)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    editText = textToRead
                    showEditSheet = true
                }) {
                    Image(systemName: "pencil")
                        .foregroundColor(settings.accentColor)
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
        .sheet(isPresented: $showSaveModal) {
            SaveTextModal(
                title: $saveTitle,
                onSave: {
                    let finalTitle = saveTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
                        ? "Untitled" 
                        : saveTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    savedStore.add(title: finalTitle, text: textToRead)
                    showSaveModal = false
                },
                onCancel: {
                    showSaveModal = false
                }
            )
        }
        .sheet(isPresented: $showEditSheet) {
            NavigationStack {
                VStack(spacing: 16) {
                    TextEditor(text: $editText)
                        .font(settings.customFont(size: settings.textSize, weight: settings.boldText ? .bold : .regular))
                        .foregroundColor(settings.textColor)
                        .padding(12)
                        .background(adaptiveTextFieldBackground)
                        .scrollContentBackground(.hidden)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    
                    Spacer()
                }
                .navigationTitle("Edit Text")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            let newText = editText
                            textToRead = newText
                            highlightedText = AttributedString(textToRead)
                            speechSynthesizer.stop()
                            speechSynthesizer.setupText(textToRead)
                            updateHighlightedText()
                            showEditSheet = false
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                }
            }
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
                    attributedString[wordRange].backgroundColor = Color.yellow.opacity(0.5)
                    attributedString[wordRange].foregroundColor = .primary
                }
            }
        }
        
        highlightedText = attributedString
    }
    
}

#Preview {
    ReadingView(
        isPresented: .constant(true),
        selectedTab: .constant(0),
        textToRead: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec magna metus, porta quis ex non, elementum rutrum turpis. Etiam volutpat eu sapien eleifend rhoncus. Donec vitae feugiat turpis. Donec volutpat purus leo, ut aliquet purus mollis vel. Nunc vitae bibendum sem, ut tristique orci. Maecenas nec urna rutrum eros venenatis placerat a id sapien. Etiam mattis lorem sit amet ipsum dapibus, vulputate viverra nulla cursus. Etiam dignissim, nibh vitae mollis sodales, orci tortor placerat nibh. vitae convallis elit nunc non"
    )
}
