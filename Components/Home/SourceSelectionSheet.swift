//
//  SourceSelectionSheet.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 15/01/26.
//

import SwiftUI

struct SourceSelectionSheet: View {
    @Binding var isPresented: Bool
    @Binding var showCamera: Bool
    @Binding var showPhotoPicker: Bool
    @Binding var showDocumentPicker: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Choose a source")
                    .font(.largeTitle.bold())
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            Divider()
            
            Spacer()
                .frame(height: 30)
            
            // Opzioni
            VStack(spacing: 0) {
                // Camera
                Button(action: {
                    isPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showCamera = true
                    }
                }) {
                    HStack(spacing: 20) {
                        Image(systemName: "camera.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                            .frame(width: 50)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Camera")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("Scan your text live")
                                .font(.subheadline)
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
                
                // Galleria
                Button(action: {
                    isPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showPhotoPicker = true
                    }
                }) {
                    HStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title)
                            .foregroundColor(.blue)
                            .frame(width: 50)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Gallery")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("Choose an existing photo")
                                .font(.subheadline)
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
                            .font(.title)
                            .foregroundColor(.blue)
                            .frame(width: 50)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Files")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("Choose a document")
                                .font(.subheadline)
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
        .presentationDetents([.medium])
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
