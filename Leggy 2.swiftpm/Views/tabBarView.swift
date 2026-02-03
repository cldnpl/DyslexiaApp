//
//  tabBarView.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 15/01/26.
//

import SwiftUI
import UIKit

struct tabBarView: View {
    @State private var selectedTab = 0
    @StateObject private var settings = AppSettings.shared
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 1 tab - Home
            buttonsView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            // 2 tab - Saved
            SavedView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
                .tag(1)
            
            // 3 tab - Settings
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(2)
        }
        .tabViewStyle(.automatic)
        .tint(settings.accentColor)
        .onAppear { updateTabBarUnselectedTint() }
        .onChange(of: settings.isDarkMode) { _ in updateTabBarUnselectedTint() }
        .onChange(of: settings.accentColor) { _ in updateTabBarUnselectedTint() }
        .toolbarBackground(Color(uiColor: .systemBackground), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
    
    private func updateTabBarUnselectedTint() {
        let accent = UIColor(settings.accentColor)
        UITabBar.appearance().unselectedItemTintColor = accent.withAlphaComponent(0.6)
    }
}
#Preview {
    tabBarView()
}
