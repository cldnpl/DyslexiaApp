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
    let originalText: String  // ← CAMBIATO DA @State A let
    @StateObject private var settings = AppSettings.shared
    
    @State private var correctedText: String = ""
    @State private var isCorrecting: Bool = true
    @State private var progressMessage: String = "Correcting your text..."
    @State private var progressValue: Double = 0.0
    @State private var timer: Timer?
    @State private var isActive = true
    @State private var hasStartedCorrection = false
    
    // Closure to pass corrected text to parent view
    var onCorrectionComplete: ((String) -> Void)?
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color(red: 65/255, green: 72/255, blue: 112/255).opacity(0.12))
                    .frame(width: 120, height: 120)
                
                Image("faceLeggy")
                    .font(.system(size: settings.textSize * 3.125))
                    .foregroundColor(settings.isDarkMode ? .primary : settings.accentColor)
                    .opacity(isCorrecting ? 1.0 : 0.5)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isCorrecting)
            }
            
            // Message
            VStack(spacing: 10) {
                Text("Correction in progress...")
                    .font(settings.customFont(size: settings.textSize * 1.75, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(progressMessage)
                    .font(settings.customFont(size: settings.textSize * 0.9375, weight: settings.boldText ? .bold : .regular))
                    .foregroundColor(.gray)
            }
            
            // Animated progressbar
            ProgressView(value: progressValue, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: settings.isDarkMode ? .primary : settings.accentColor))
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding(.horizontal, 50)
                .animation(.linear(duration: 0.3), value: progressValue)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .task {  // ← CAMBIATO DA onAppear A task
            if !hasStartedCorrection {
                hasStartedCorrection = true
                await performCorrection()  // ← Ora async
            }
        }
        .onDisappear {
            cleanup()
        }
    }
    
    private func cleanup() {
        timer?.invalidate()
        timer = nil
        isActive = false
    }
    
    @MainActor  // ← Assicura che tutto giri sul main thread
    private func performCorrection() async {
        // Guard: if text is empty, complete immediately
        guard !originalText.isEmpty else {
            self.correctedText = ""
            self.isCorrecting = false
            self.progressValue = 1.0
            self.progressMessage = "Completed!"
            self.onCorrectionComplete?("")
            return
        }
        
        // Reset activity flag
        isActive = true
        
        // Invalida il timer esistente se presente
        timer?.invalidate()
        timer = nil
        
        // Reset del progresso
        progressValue = 0.0
        progressMessage = "Analyzing text..."
        isCorrecting = true
        
        // Call real AI correction with progress callback
        TextCorrectionHelper.correctText(
            originalText,
            progressCallback: { progress, message in
                // Update progress and message on main UI
                Task { @MainActor in
                    guard self.isActive else { return }
                    self.progressValue = progress
                    self.progressMessage = message
                }
            },
            completion: { corrected in
                Task { @MainActor in
                    guard self.isActive else { return }
                    
                    // If correction succeeded, use corrected text; otherwise use original
                    self.correctedText = corrected ?? self.originalText
                    self.isCorrecting = false
                    self.progressValue = 1.0
                    self.progressMessage = "Completed!"
                    
                    // Invalidate timer if still active
                    self.timer?.invalidate()
                    self.timer = nil
                    
                    // Pass corrected text to parent view and navigate
                    try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 secondi
                    
                    guard self.isActive else { return }
                    self.onCorrectionComplete?(self.correctedText)
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
            originalText: "Sample text with spelling errors",
            onCorrectionComplete: { _ in }
        )
    }
}
