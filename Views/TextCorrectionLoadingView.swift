//
//  TextCorrectionLoadingView.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 18/01/26.
//

import SwiftUI
import Foundation

struct TextCorrectionLoadingView: View {
    @Binding var isPresented: Bool
    @Binding var selectedTab: Int
    @State var originalText: String
    @StateObject private var settings = AppSettings.shared
    @State private var correctedText: String = ""
    @State private var isCorrecting: Bool = true
    @State private var progressMessage: String = "Correcting your text..."
    @State private var progressValue: Double = 0.0
    @State private var timer: Timer?
    @State private var isActive = true
    
    // Closure per comunicare il testo corretto alla vista parent
    var onCorrectionComplete: ((String) -> Void)?
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color(red: 65/255, green: 72/255, blue: 112/255).opacity(0.12))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "sparkles")
                    .font(.system(size: settings.textSize * 3.125))
                    .foregroundColor(settings.isDarkMode ? .primary : .blue)
                    .symbolEffect(.pulse, options: .repeating)
            }
            
            // Message
            VStack(spacing: 10) {
                Text("Correction in progress...")
                    .font(.app(size: settings.textSize * 1.75, weight: .bold, dyslexia: settings.dyslexiaFont))
                    .foregroundColor(.primary)
                
                Text(progressMessage)
                    .font(.app(size: settings.textSize * 0.9375, weight: settings.boldText ? .bold : .regular, dyslexia: settings.dyslexiaFont))
                    .foregroundColor(.gray)
            }
            
            // Animated progressbar
            ProgressView(value: progressValue, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: settings.isDarkMode ? .primary : .blue))
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding(.horizontal, 50)
                .animation(.linear(duration: 0.3), value: progressValue)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            startCorrection()
        }
        .onDisappear {
            timer?.invalidate()
            isActive = false
        }
    }
    
    private func startCorrection() {
        // Protezione: se il testo è vuoto, completa immediatamente
        guard !originalText.isEmpty else {
            DispatchQueue.main.async {
                self.correctedText = ""
                self.isCorrecting = false
                self.progressValue = 1.0
                self.progressMessage = "Completato!"
                self.onCorrectionComplete?("")
            }
            return
        }
        
        // Reset flag di attività
        isActive = true
        
        // Invalida il timer esistente se presente
        timer?.invalidate()
        timer = nil
        
        // Reset del progresso
        progressValue = 0.0
        progressMessage = "Analizzando il testo..."
        isCorrecting = true
        
        // Chiama la correzione AI reale con callback per il progresso
        TextCorrectionHelper.correctText(
            originalText,
            progressCallback: { progress, message in
                // Aggiorna il progresso e il messaggio sulla UI principale
                DispatchQueue.main.async {
                    guard self.isActive else { return }
                    self.progressValue = progress
                    self.progressMessage = message
                }
            },
            completion: { corrected in
                DispatchQueue.main.async {
                    guard self.isActive else { return }
                    
                    // Se la correzione è andata a buon fine, usa il testo corretto
                    // Altrimenti usa il testo originale
                    self.correctedText = corrected ?? self.originalText
                    self.isCorrecting = false
                    self.progressValue = 1.0
                    self.progressMessage = "Completato!"

                    // Invalida il timer se ancora attivo (non dovrebbe esserlo)
                    self.timer?.invalidate()
                    self.timer = nil

                    // Comunica il testo corretto alla vista parent e naviga
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        guard self.isActive else { return }
                        self.onCorrectionComplete?(self.correctedText)
                    }
                }
            }
        )
    }
}

#Preview {
    NavigationStack {
        TextCorrectionLoadingView(
            isPresented: .constant(true),
            selectedTab: .constant(0),
            originalText: "Testo di esempio con errori ortografici",
            onCorrectionComplete: { _ in }
        )
    }
}
