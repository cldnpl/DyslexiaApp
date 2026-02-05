//
//  SourceSelectionSheet.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 15/01/26.
//

import SwiftUI
import UIKit

struct SourceSelectionSheet: View {
    @Binding var isPresented: Bool
    @Binding var showCamera: Bool
    @Binding var showPhotoPicker: Bool
    @Binding var showDocumentPicker: Bool
    @StateObject private var settings = AppSettings.shared
    
    // Check if camera is available
    private var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Choose a source")
                    .font(settings.customFont(size: settings.textSize * 2.125, weight: .bold))
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: settings.textSize * 1.375))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            Divider()
            
            Spacer()
                .frame(height: 30)
            
            // Options
            VStack(spacing: 0) {
                // Camera (only if available)
                if isCameraAvailable {
                    Button(action: {
                        isPresented = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showCamera = true
                        }
                    }) {
                        HStack(spacing: 20) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: settings.textSize * 1.75))
                                .foregroundColor(settings.isDarkMode ? .primary : settings.accentColor)
                                .frame(width: 50)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Camera")
                                    .font(settings.customFont(size: settings.textSize * 1.0625, weight: .bold))
                                    .foregroundColor(.primary)
                                Text("Scan your text live")
                                    .font(settings.customFont(size: settings.textSize * 0.9375, weight: settings.boldText ? .bold : .regular))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                    
                    Divider()
                        .padding(.leading, 70)
                }
                
                // Gallery
                Button(action: {
                    isPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showPhotoPicker = true
                    }
                }) {
                    HStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: settings.textSize * 1.75))
                            .foregroundColor(settings.isDarkMode ? .primary : settings.accentColor)
                            .frame(width: 50)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Gallery")
                                .font(settings.customFont(size: settings.textSize * 1.0625, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Choose an existing photo")
                                .font(settings.customFont(size: settings.textSize * 0.9375, weight: settings.boldText ? .bold : .regular))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
                
                Divider()
                    .padding(.leading, 70)
                
                // Files
                Button(action: {
                    isPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showDocumentPicker = true
                    }
                }) {
                    HStack(spacing: 20) {
                        Image(systemName: "folder.fill")
                            .font(.system(size: settings.textSize * 1.75))
                            .foregroundColor(settings.isDarkMode ? .primary : settings.accentColor)
                            .frame(width: 50)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Files")
                                .font(settings.customFont(size: settings.textSize * 1.0625, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Choose a document")
                                .font(settings.customFont(size: settings.textSize * 0.9375, weight: settings.boldText ? .bold : .regular))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
            }
            
            Spacer()
                .frame(height: 40)
        }
        .presentationDetents([UIDevice.current.userInterfaceIdiom == .pad ? .large : .medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    SourceSelectionSheet(
        isPresented: .constant(true),
        showCamera: .constant(false),
        showPhotoPicker: .constant(false),
        showDocumentPicker: .constant(false)
    )
}
