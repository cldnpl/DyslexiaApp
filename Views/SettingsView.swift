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
                        HStack(alignment: .center) {
                            Text("About me")
                                .font(settings.customFont(size: settings.textSize, weight: settings.boldText ? .bold : .regular))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .frame(minHeight: max(44, settings.textSize * 2.1), alignment: .center)
                    }
                    .buttonStyle(.plain)
                }
                }
                .scrollContentBackground(.hidden)
                .padding(.top, 24)

                Text("This app follows the accessibility settings on your iPhone.")
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 30)
                    .padding(.top, 8)
                    .padding(.bottom, 60)
             
                Spacer()
                
                Image("settingsLeggy")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.vertical, 20)
                    .offset(y: -50)
            }
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
