//
//  SettingsView.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 21/01/26.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = AppSettings.shared
    @State private var showFontSelection = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: settings.isDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(settings.isDarkMode ? .white : .blue)
                            .frame(width: 30)
                        
                        Text("Dark Mode")
                            .font(.app(size: settings.textSize, weight: settings.boldText ? .bold : .regular, dyslexia: settings.dyslexiaFont))
                            .foregroundColor(settings.isDarkMode ? .white : .primary)
                        
                        Spacer()
                        
                        Toggle("", isOn: $settings.isDarkMode)
                    }
                } header: {
                    Text("APPEARANCE")
                        .font(.app(size: settings.textSize * 0.875, weight: .bold, dyslexia: settings.dyslexiaFont))
                        .foregroundColor(settings.isDarkMode ? .white : .primary)
                }
                Section {
                    Button(action: {
                        showFontSelection = true
                    }) {
                        HStack {
                            Image(systemName: "character.magnify")
                                .foregroundColor(settings.isDarkMode ? .white : .blue)
                                .frame(width: 30)
                            
                            Text("Font")
                                .font(.app(size: settings.textSize, weight: settings.boldText ? .bold : .regular, dyslexia: settings.dyslexiaFont))
                                .foregroundColor(settings.isDarkMode ? .white : .primary)
                            
                            Spacer()
                            
                            Text(settings.selectedFont.displayName)
                                .font(.app(size: settings.textSize, weight: settings.boldText ? .bold : .regular, font: settings.selectedFont))
                                .foregroundColor(settings.isDarkMode ? .white.opacity(0.9) : .secondary)
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(settings.isDarkMode ? .white : .secondary)
                                .font(.system(size: 14))
                        }
                    }
                    .buttonStyle(.plain)
                    
                    HStack {
                        Image(systemName: "textformat.size")
                            .foregroundColor(settings.isDarkMode ? .white : .blue)
                        Text("Text Size")
                            .font(.app(size: settings.textSize, weight: settings.boldText ? .bold : .regular, dyslexia: settings.dyslexiaFont))
                            .foregroundColor(settings.isDarkMode ? .white : Color.primary)
                        
                        Spacer()
                        
                        Text("\(Int(settings.textSize))")
                            .font(.app(size: settings.textSize, weight: settings.boldText ? .bold : .regular, dyslexia: settings.dyslexiaFont))
                            .foregroundColor(settings.isDarkMode ? .white.opacity(0.9) : .secondary)
                        
                        Stepper("", value: $settings.textSize, in: 12...24, step: 1)
                    }
                    
                    HStack {
                        Image(systemName: "bold")
                            .foregroundColor(settings.isDarkMode ? .white : .blue)
                            .frame(width: 30)
                        
                        Text("Bold Text")
                            .font(.app(size: settings.textSize, weight: settings.boldText ? .bold : .regular, dyslexia: settings.dyslexiaFont))
                            .foregroundColor(settings.isDarkMode ? .white : .primary)
                        
                        Spacer()
                        
                        Toggle("", isOn: $settings.boldText)
                    }
                    HStack {
                        Image(systemName: "circle.lefthalf.filled")
                            .foregroundColor(settings.isDarkMode ? .white : .blue)
                            .frame(width: 30)
                        
                        Text("Color Contrast")
                            .font(.app(size: settings.textSize, weight: settings.boldText ? .bold : .regular, dyslexia: settings.dyslexiaFont))
                            .foregroundColor(settings.isDarkMode ? .white : .primary)
                        
                        Spacer()
                        
                        Toggle("", isOn: $settings.colorContrast)
                    }
                    HStack {
                        Image(systemName: "speaker.wave.2")
                            .foregroundColor(settings.isDarkMode ? .white : .blue)
                            .frame(width: 30)
                        
                        Text("Voice Over")
                            .font(.app(size: settings.textSize, weight: settings.boldText ? .bold : .regular, dyslexia: settings.dyslexiaFont))
                            .foregroundColor(settings.isDarkMode ? .white : .primary)
                        Toggle("", isOn: $settings.voiceOverEnabled)
                    } } header: {
                        Text("ACCESSIBILITY")
                            .font(.app(size: settings.textSize * 0.875, weight: .bold, dyslexia: settings.dyslexiaFont))
                            .foregroundColor(settings.isDarkMode ? .white : .primary)
                    }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showFontSelection) {
                FontSelectionSheet(isPresented: $showFontSelection)
            }
        }
    }
}
#Preview {
    SettingsView()
}
