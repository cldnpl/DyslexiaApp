//
//  tabBarView.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 15/01/26.
//

import SwiftUI

struct tabBarView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 1 tab - Home
            firstPageView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            // 2 tab - Saved
            Text("Saved page")
                .tabItem {
                    Image(systemName: "bookmark.fill")
                    Text("Saved")
                }
                .tag(1)
            
            // 3 tab - Settings
            Text("Setting Page")
                .font(.largeTitle)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(2)
        }
        .tint(Color(red: 65/255, green: 112/255, blue: 72/255))
        .toolbarBackground(Color(red: 182/255, green: 212/255, blue: 177/255), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
       
}
#Preview {
    tabBarView()
}
