//
//  FontSelectionSheet.swift
//  DyslexiaReader
//

import SwiftUI

struct FontSelectionSheet: View {
    @Binding var isPresented: Bool
    @StateObject private var settings = AppSettings.shared
    @State private var selectedFont: AppFont
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self._selectedFont = State(initialValue: AppSettings.shared.selectedFont)
    }
    
    // Filtra solo i font disponibili
    private var availableFonts: [AppFont] {
        AppFont.allCases.filter { font in
            // System è sempre disponibile, OpenDyslexic è nel progetto
            if font == .system || font == .openDyslexic {
                return true
            }
            // Per gli altri, verifica se sono disponibili nel sistema
            return font.isAvailable()
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(availableFonts, id: \.self) { font in
                    Button(action: {
                        selectedFont = font
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(font.displayName)
                                    .font(.app(size: 17, weight: .regular, font: font))
                                    .foregroundColor(selectedFont == font ? .primary : .primary)
                                
                                // Preview del font con testo di esempio
                                Text("The quick brown fox jumps over the lazy dog")
                                    .font(.app(size: 14, weight: .regular, font: font))
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                            
                            if selectedFont == font {
                                Image(systemName: "checkmark")
                                    .foregroundColor(settings.isDarkMode ? .primary : .blue)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .contentShape(Rectangle())
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Font")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        settings.selectedFont = selectedFont
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
