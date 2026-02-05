//
//  SaveTextModal.swift
//  Leggy
//
//  Created by Auto on 27/01/26.
//

import SwiftUI

struct SaveTextModal: View {
    @Binding var title: String
    let onSave: () -> Void
    let onCancel: () -> Void
    @StateObject private var settings = AppSettings.shared
    @FocusState private var isTextFieldFocused: Bool
    
    private var buttonFill: Color {
        settings.isDarkMode
            ? Color(uiColor: .secondarySystemGroupedBackground)
            : Color(uiColor: .systemGray6)
    }
    
    private var buttonStroke: Color {
        settings.isDarkMode
            ? Color(uiColor: .separator)
            : Color.black.opacity(0.08)
    }
    
    private var buttonShadow: Color {
        settings.isDarkMode
            ? Color.black.opacity(0.18)
            : Color.black.opacity(0.10)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                Text("Save your text")
                    .font(settings.customFont(size: settings.textSize * 1.75, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.top, 44)
                
                TextField("Text 1", text: $title)
                    .font(settings.customFont(size: settings.textSize, weight: .regular))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Rectangle()
                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(Color(uiColor: .separator))
                                    .offset(y: -1),
                                alignment: .bottom
                            )
                    )
                    .focused($isTextFieldFocused)
                    .padding(.horizontal, 20)
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(settings.customFont(size: settings.textSize, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(buttonFill)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(buttonStroke, lineWidth: 1)
                                    )
                                    .shadow(color: buttonShadow, radius: 8, x: 0, y: 4)
                            }
                    }
                    
                    Button(action: onSave) {
                        Text("Save")
                            .font(settings.customFont(size: settings.textSize, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(buttonFill)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(buttonStroke, lineWidth: 1)
                                    )
                                    .shadow(color: buttonShadow, radius: 8, x: 0, y: 4)
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(uiColor: .systemBackground))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isTextFieldFocused = true
                }
            }
        }
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    SaveTextModal(
        title: .constant(""),
        onSave: {},
        onCancel: {}
    )
}
