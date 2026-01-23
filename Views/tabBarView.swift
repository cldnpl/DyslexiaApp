//
//  tabBarView.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 15/01/26.
//

import SwiftUI

struct tabBarView: View {
    @State private var selectedTab = 0
    @StateObject private var settings = AppSettings.shared
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 1 tab - Home
            buttonsView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            // 2 tab - Saved
            Text("Saved page")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: .systemBackground))
                .tabItem {
                    Image(systemName: "bookmark.fill")
                    Text("Saved")
                }
                .tag(1)
            
            // 3 tab - Settings
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(2)
        }
        .tint(settings.isDarkMode ? .primary : .blue)
        .toolbarBackground(Color(uiColor: .systemBackground), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
       
}
#Preview {
    tabBarView()
}
