//
//  firstPageView.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 13/01/26.
//

import SwiftUI

struct buttonsView: View {
    @Binding var selectedTab: Int
    @StateObject private var settings = AppSettings.shared
    @State private var showDyslexiaInfo = false
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
            ScrollView {
                VStack(spacing: 12) {
                    // Card: Scan your text
                    Button(action: { showSourceSelection = true }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Image(systemName: "camera")
                                    .font(.system(size: settings.textSize * 4.375))
                                    .foregroundColor(settings.accentColor)
                                Text("Scan your text")
                                    .font(settings.customFont(size: settings.textSize * 1.5, weight: .bold))
                                    .foregroundColor(.primary)
                                Text("Open the camera, select a photo or a file...and let Leggy help you")
                                    .font(settings.customFont(size: settings.textSize * 0.875, weight: settings.boldText ? .bold : .regular))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                .shadow(radius: 5)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    
                    // Card: Insert manually
                    Button(action: { showInsertManually = true }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Image(systemName: "pencil.and.scribble")
                                    .font(.system(size: settings.textSize * 4.375))
                                    .foregroundColor(settings.accentColor)
                                Text("Insert manually")
                                    .font(settings.customFont(size: settings.textSize * 1.5, weight: .bold))
                                    .foregroundColor(.primary)
                                Text("Type and correct your text by yourself")
                                    .font(settings.customFont(size: settings.textSize * 0.875, weight: settings.boldText ? .bold : .regular))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                .shadow(radius: 5)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    
                    Image("readingLeggy")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350, height: 350)
                        .padding(.top, -100)
                    
                    Spacer(minLength: 8)
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
            }
            .scrollDisabled(true)
            .background(Color(uiColor: .systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showDyslexiaInfo = true }) {
                        Image(systemName: "info.circle")
                    }
                           
                }

            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
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
                        // When correction is complete, save text and go to ReadingView
                        self.extractedText = corrected
                        self.showCorrectionLoading = false
                        // Navigate to ReadingView after short delay to allow previous view to close
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
        .sheet(isPresented: $showDyslexiaInfo) {
            DyslexiaInfoSheet()
        }
    }
    
    private func processImage(_ image: UIImage) {
        // Resize image in background if needed
        DispatchQueue.global(qos: .userInitiated).async {
            let resizedImage = Self.resizeImageIfNeeded(image, maxDimension: 2000)
            
            // Process text recognition
            TextRecognitionHelper.recognizeText(from: resizedImage) { text in
                // Callback is already on main thread
                DispatchQueue.main.async {
                    if let recognizedText = text, !recognizedText.isEmpty {
                        self.extractedText = recognizedText
                        // Navigate directly to correction view
                        self.showCorrectionLoading = true
                    } else {
                        // Show error message if no text was recognized
                        self.extractedText = "No text recognized in the image. Try with a clearer image."
                        self.showCorrectionLoading = true
                    }
                }
            }
        }
    }
    
    private func processImages(_ images: [UIImage]) {
        // Process multiple images concurrently with thread-safe array access
        final class TextCollector: @unchecked Sendable {
            private let lock = NSLock()
            private var texts: [String] = []
            
            func add(_ text: String) {
                lock.lock()
                defer { lock.unlock() }
                texts.append(text)
            }
            
            func getAll() -> [String] {
                lock.lock()
                defer { lock.unlock() }
                return texts
            }
        }
        
        let textCollector = TextCollector()
        let group = DispatchGroup()
        
        for image in images {
            group.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                let resizedImage = Self.resizeImageIfNeeded(image, maxDimension: 2000)
                
                TextRecognitionHelper.recognizeText(from: resizedImage) { text in
                    if let recognizedText = text, !recognizedText.isEmpty {
                        textCollector.add(recognizedText)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            let textArray = textCollector.getAll()
            if textArray.isEmpty {
                self.extractedText = "No text recognized in the images. Try with clearer images."
            } else {
                // Combine all recognized text with double line breaks
                self.extractedText = textArray.joined(separator: "\n\n")
            }
            self.showCorrectionLoading = true
        }
    }
    
    private static nonisolated func resizeImageIfNeeded(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let maxSize = max(size.width, size.height)
        
        // If image is already smaller than max dimension, return as is
        guard maxSize > maxDimension else {
            return image
        }
        
        // Calculate new size keeping aspect ratio
        let ratio = maxDimension / maxSize
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        // Resize the image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }
    
    private func processDocument(_ url: URL) {
        // Get file access
        let _ = url.startAccessingSecurityScopedResource()
        defer { url.stopAccessingSecurityScopedResource() }
        
        TextRecognitionHelper.extractText(from: url) { text in
            DispatchQueue.main.async {
                if let extracted = text, !extracted.isEmpty {
                    self.extractedText = extracted
                    self.showCorrectionLoading = true
                } else {
                    // Show error message if text could not be extracted
                    self.extractedText = "Unable to extract text from the selected document."
                    self.showCorrectionLoading = true
                }
            }
        }
    }
}
#Preview {
    buttonsView(selectedTab: .constant(0))
}
