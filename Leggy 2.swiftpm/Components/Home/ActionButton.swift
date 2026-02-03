//
//  ActionButton.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 14/01/26.
//

import SwiftUI

struct ActionButton: View {
    let iconName: String
    let title: String
    let description: String
    let action: () -> Void
    @StateObject private var settings = AppSettings.shared
    
    private let accentBlue = Color(red: 65/255, green: 72/255, blue: 112/255)
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: settings.textSize * 2.75))
                    .foregroundColor(accentBlue)
                
                Text(title)
                    .font(settings.customFont(size: settings.textSize * 1.0625, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(settings.customFont(size: settings.textSize * 0.9375, weight: settings.boldText ? .bold : .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
            .shadow(color: Color.black.opacity(settings.isDarkMode ? 0.3 : 0.08), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    VStack(spacing: 20) {
        ActionButton(
            iconName: "camera",
            title: "Scan your text",
            description: "Open the camera, select a photo or a file, and let the app help you",
            action: {}
        )
        ActionButton(
            iconName: "pencil.and.scribble",
            title: "Insert manually",
            description: "Type and correct your text by yourself",
            action: {}
        )
    }
}
