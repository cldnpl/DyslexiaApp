//
//  FontSelectionSheet.swift
//  DyslexiaReader
//
import SwiftUI

struct FontSelectionSheet: View {
    @Binding var isPresented: Bool
    @StateObject private var settings = AppSettings.shared
    @State private var selectedFont: String
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self._selectedFont = State(initialValue: AppSettings.shared.selectedFont)
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(AppSettings.availableFonts, id: \.self) { fontName in
                    Button(action: {
                        selectedFont = fontName
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(fontName)
                                    .font(fontForPreview(fontName: fontName))
                                    .foregroundColor(selectedFont == fontName ? .primary : .primary)
                            }
                            
                            Spacer()
                            
                            if selectedFont == fontName {
                                Image(systemName: "checkmark")
                                    .foregroundColor(settings.isDarkMode ? .primary : settings.accentColor)
                                    .font(.system(size: UIFont.preferredFont(forTextStyle: .body).pointSize * 0.94, weight: .semibold))
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
    
    // Helper per ottenere il font corretto per la preview
    private func fontForPreview(fontName: String) -> Font {
        let systemBodySize = UIFont.preferredFont(forTextStyle: .body).pointSize
        let systemBaseSize: CGFloat = 17.0
        let scaleFactor = 17.0 / systemBaseSize
        let dynamicSize = systemBodySize * scaleFactor
        
        if fontName == "System" {
            return .system(size: dynamicSize, weight: .regular)
        }
        
        let actualFontName = AppSettings.fontName(for: .regular, fontName: fontName)
        return Font.custom(actualFontName, size: dynamicSize)
    }
}
