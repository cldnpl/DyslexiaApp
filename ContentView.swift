import SwiftUI

extension AnyTransition {
    static var fadeAndScale: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity),
            removal: .scale(scale: 1.1).combined(with: .opacity)
            )
    }
}
struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var settings = AppSettings.shared
    
    var body: some View {
        Group {
            if settings.hasCompletedOnboarding {
                tabBarView()
                    .tint(settings.accentColor)
                    .onChange(of: colorScheme) { _ in
                        // Forza l'aggiornamento quando cambia il color scheme
                        settings.updateForColorSchemeChange()
                    }
            } else {
                OnboardingView()
                    .transition(.fadeAndScale)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: settings.hasCompletedOnboarding)
    }
}
