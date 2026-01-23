//
//  firstPageView.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 13/01/26.
//

import SwiftUI

struct buttonsView: View {
    @Binding var selectedTab: Int
    @State private var showSourceSelection = false
    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var showDocumentPicker = false
    @State private var showInsertManually = false
    @State private var showCorrectionLoading = false
    @State private var showReadingView = false
    @State private var extractedText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                
                // Card: Scan your text
                Button(action: { showSourceSelection = true }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 12) {
                            Image(systemName: "camera")
                                .font(.system(size: 70))
                                .foregroundColor(.blue)
                            Text("Scan your text")
                                .font(.system(size: 40).bold())
                                .font(.largeTitle.bold())
                                .foregroundColor(.black)
                            Text("Open the camera, select a photo or a file...and let the app help you")
                                .font(.system(size: 15))
                                .font(.subheadline)
                                .foregroundColor(Color.gray.opacity(0.6))
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white)
                    )
                    .shadow(radius: 5)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                
                // Card: Insert manually
                Button(action: { showInsertManually = true }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 12) {
                            Image(systemName: "pencil.and.scribble")
                                .font(.system(size: 70))
                                .foregroundColor(.blue)
                            Text("Insert manually")
                                .font(.system(size: 40).bold())
                                .font(.largeTitle.bold())
                                .foregroundColor(.black)
                            Text("Type and correct your test by yourself")
                                .font(.subheadline)
                                .font(.system(size: 15))
                                .foregroundColor(Color.gray.opacity(0.6))
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white)
                    )
                    .shadow(radius: 5)

                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationDestination(isPresented: $showInsertManually) {
                InsertManuallyView(
                    isPresented: $showInsertManually,
                    selectedTab: $selectedTab
                )
            }
            .navigationDestination(isPresented: $showCorrectionLoading) {
                TextCorrectionLoadingView(
                    isPresented: $showCorrectionLoading,
                    selectedTab: $selectedTab,
                    originalText: extractedText,
                    onCorrectionComplete: { corrected in
                        // Quando la correzione è completa, salva il testo e vai a ReadingView
                        self.extractedText = corrected
                        self.showCorrectionLoading = false
                        // Naviga a ReadingView dopo un breve delay per permettere la chiusura della vista precedente
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.showReadingView = true
                        }
                    }
                )
            }
            .navigationDestination(isPresented: $showReadingView) {
                ReadingView(
                    isPresented: $showReadingView,
                    selectedTab: $selectedTab,
                    textToRead: extractedText
                )
            }
        }
        .sheet(isPresented: $showSourceSelection) {
            SourceSelectionSheet(
                isPresented: $showSourceSelection,
                showCamera: $showCamera,
                showPhotoPicker: $showPhotoPicker,
                showDocumentPicker: $showDocumentPicker
            )
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker(isPresented: $showCamera) { image in
                processImage(image)
            }
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker(isPresented: $showPhotoPicker) { image in
                processImage(image)
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(isPresented: $showDocumentPicker) { url in
                processDocument(url)
            }
        }
    }
    
    private func processImage(_ image: UIImage) {
        // Ridimensiona l'immagine in background se necessario
        DispatchQueue.global(qos: .userInitiated).async {
            let resizedImage = self.resizeImageIfNeeded(image, maxDimension: 2000)
            
            // Processa il riconoscimento del testo
            TextRecognitionHelper.recognizeText(from: resizedImage) { text in
                // Il callback è già sul main thread
                if let recognizedText = text, !recognizedText.isEmpty {
                    self.extractedText = recognizedText
                    // Naviga direttamente alla vista di correzione
                    self.showCorrectionLoading = true
                } else {
                    // Mostra un messaggio di errore se non è stato riconosciuto testo
                    self.extractedText = "Nessun testo riconosciuto nell'immagine. Prova con un'immagine più chiara."
                    self.showCorrectionLoading = true
                }
            }
        }
    }
    
    private func resizeImageIfNeeded(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let maxSize = max(size.width, size.height)
        
        // Se l'immagine è già più piccola della dimensione massima, restituiscila così com'è
        guard maxSize > maxDimension else {
            return image
        }
        
        // Calcola il nuovo size mantenendo le proporzioni
        let ratio = maxDimension / maxSize
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        // Ridimensiona l'immagine
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }
    
    private func processDocument(_ url: URL) {
        // Ottieni l'accesso al file
        let _ = url.startAccessingSecurityScopedResource()
        defer { url.stopAccessingSecurityScopedResource() }
        
        TextRecognitionHelper.extractText(from: url) { text in
            DispatchQueue.main.async {
                if let extracted = text, !extracted.isEmpty {
                    self.extractedText = extracted
                    self.showCorrectionLoading = true
                } else {
                    // Mostra un messaggio di errore se non è stato possibile estrarre il testo
                    self.extractedText = "Impossibile estrarre il testo dal documento selezionato."
                    self.showCorrectionLoading = true
                }
            }
        }
    }
}
#Preview {
    buttonsView(selectedTab: .constant(0))
}
