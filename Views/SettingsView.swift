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
    @State private var showAboutMe = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {

                    Section {
                    // Accent Color Picker
                    HStack {
                        Text("Theme Color")
                            .font(settings.customFont(size: settings.textSize, weight: settings.boldText ? .bold : .regular))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        ColorPicker("", selection: Binding(
                            get: { settings.accentColor },
                            set: { settings.accentColor = $0 }
                        ))
                        .labelsHidden()
                    }
                    
                    
                    // Text Field Background Color Picker
                    HStack {
                        Text("Text Field Color")
                            .font(settings.customFont(size: settings.textSize, weight: settings.boldText ? .bold : .regular))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        ColorPicker("", selection: Binding(
                            get: { settings.textFieldBackgroundColor },
                            set: { settings.textFieldBackgroundColor = $0 }
                        ))
                        .labelsHidden()
                    }
                    
                    // Font Selection
                    Button(action: {
                        showFontSelection = true
                    }) {
                        HStack {
                            Text("Font")
                                .font(settings.customFont(size: settings.textSize, weight: settings.boldText ? .bold : .regular))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(settings.selectedFont)
                                .font(settings.customFont(size: settings.textSize, weight: settings.boldText ? .bold : .regular))
                                .foregroundColor(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .buttonStyle(.plain)
                    
                    // About me Button
                    Button(action: {
                        showAboutMe = true
                    }) {
                        HStack {
                            Text("About me")
                                .font(settings.customFont(size: settings.textSize, weight: settings.boldText ? .bold : .regular))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .buttonStyle(.plain)
                    
                    // Reset Colors Button
                    Button(action: {
                        settings.resetColorsToDefault()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14, weight: .semibold))
                            
                            Text("Reset Colors")
                                .font(settings.customFont(size: settings.textSize, weight: settings.boldText ? .bold : .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                }
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .padding(.horizontal, 5)
                .padding(.top, 10)
                .padding(.bottom, settings.selectedFont.contains("OpenDyslexic") ? 0 : -8)

                Text("This app follows the accessibility settings on your iPhone.")
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.leading, 10)
                    .padding(.top, 4)
                    .fixedSize(horizontal: false, vertical: true)
             
                Spacer()
                
                Image("settingsLeggy")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.top, 0)
                    .padding(.bottom, 20)
            }
            .adaptiveMaxWidth(700)
            .background(Color(uiColor: .systemGroupedBackground))

            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showFontSelection) {
                FontSelectionSheet(isPresented: $showFontSelection)
            }
            .navigationDestination(isPresented: $showAboutMe) {
                SwiftUIView()
            }
        }
    }
}

#Preview {
    SettingsView()
}
