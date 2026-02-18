//
//  OnboardingView.swift
//  Leggy
//
//  Created by Claudia Napolitano on 02/02/26.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var settings = AppSettings.shared
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(
            imageName: "cheeringLeggy",
            title: "Hi, I'm Leggy!",
            subtitle: "Your new reading buddy"
        ),
        OnboardingPage(
            imageName: "standingLeggy",
            title: "I'll help you love reading again",
            subtitle: nil
        ),
        OnboardingPage(
            imageName: "heartLeggy",
            title: "Let's dive in!",
            subtitle: nil
        )
    ]
    
    var body: some View {
        ZStack {
            Color(uiColor: .secondarySystemGroupedBackground)
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .padding(.bottom, pages[index].imageName == "heartLeggy" ? 50 : 0)
                        .tag(index)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            VStack {
                Spacer()
                
                if currentPage == pages.count - 1 {
                    Button(action: {
                        settings.hasCompletedOnboarding = true
                    }) {
                        Text("Get Started")
                            .font(settings.customFont(size: settings.textSize * 1.2, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(settings.accentColor)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

struct OnboardingPage {
    let imageName: String
    let title: String
    let subtitle: String?
}

struct OnboardingPageView: View {
    @StateObject private var settings = AppSettings.shared
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Immagine di Leggy - tutte alla stessa altezza
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 300)
                .frame(maxHeight: 300, alignment: .bottom)
            
            VStack(spacing: 12) {
                Text(page.title)
                    .font(settings.customFont(size: settings.textSize * 2.2, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                if let subtitle = page.subtitle {
                    Text(subtitle)
                        .font(settings.customFont(size: settings.textSize * 1.3, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}
