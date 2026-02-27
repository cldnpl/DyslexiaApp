import SwiftUI
import UIKit

private struct AdaptiveWidthModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    let maxWidth: CGFloat
    
    private var isIPadLikeLayout: Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        }
        return horizontalSizeClass == .regular && verticalSizeClass != .compact
    }
    
    func body(content: Content) -> some View {
        Group {
            if isIPadLikeLayout {
                content
                    .frame(maxWidth: maxWidth)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                content
            }
        }
    }
}

extension View {
    func adaptiveMaxWidth(_ maxWidth: CGFloat = 700) -> some View {
        modifier(AdaptiveWidthModifier(maxWidth: maxWidth))
    }
}

