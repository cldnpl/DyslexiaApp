//
//  SettingsView.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 21/01/26.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = AppSettings.shared
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: settings.isDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(Color.black)
                            .frame(width: 30)
                        
                        Text("Dark Mode")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Toggle("", isOn: $settings.isDarkMode)
                    }
                } header: {
                    Text("APPEARANCE")
                }
                Section {
                    HStack {
                        Image(systemName: "character.magnify")
                            .foregroundColor(Color.black)
                            .frame(width: 30)
                        
                        Text("Dyslexia Font")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Toggle("", isOn: $settings.dyslexiaFont)
                    }
                    
                    HStack {
                        Image(systemName: "textformat.size")
                            .foregroundColor(.primary)
                        Text("Text Size")
                            .foregroundColor(Color.primary)
                        
                        Spacer()
                        
                        Text("\(Int(settings.textSize))")
                            .foregroundColor(.secondary)
                        
                        Stepper("", value: $settings.textSize, in: 12...24, step: 1)
                    }
                    
                    HStack {
                        Image(systemName: "bold")
                            .foregroundColor(Color.black)
                            .frame(width: 30)
                        
                        Text("Bold Text")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Toggle("", isOn: $settings.boldText)
                    }
                    HStack {
                        Image(systemName: "circle.lefthalf.filled")
                            .foregroundColor(Color.black)
                            .frame(width: 30)
                        
                        Text("Color Contrast")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Toggle("", isOn: $settings.colorContrast)
                    }
                    HStack {
                        Image(systemName: "speaker.wave.2")
                            .foregroundColor(.black)
                            .frame(width: 30)
                        
                        Text("Voice Over")
                        Toggle("", isOn: $settings.voiceOverEnabled)
                    } } header: {
                        Text("ACCESSIBILITY")}
            }
            .navigationTitle("Settings")
        }
    }
}
#Preview {
    SettingsView()
}
