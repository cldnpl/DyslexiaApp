//
//  DyslexiaReaderApp.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 13/01/26.
//

import SwiftUI

@main
struct DyslexiaReaderApp: App {
    @StateObject private var settings = AppSettings.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(settings.isDarkMode ? .dark : .light)
        }
    }
}
