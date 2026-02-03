//
//  SwiftUIView.swift
//  Leggy
//
//  Created by Claudia Napolitano on 01/02/26.
//
import SwiftUI

struct SwiftUIView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settings = AppSettings.shared  // ← AGGIUNGI QUESTA RIGA
    
    var body: some View {
        ScrollView {
            Spacer()
            ZStack {
                Rectangle()
                    .cornerRadius(30)
                    .foregroundColor(.gray.opacity(0.1))
                    .frame(width: 350, height: 1100)
                
                Text("I'm Claudia Napolitano, and I'm an Italian student currently in my third year of Psychology and my first year at the Apple Developer Academy (Naples).\nI'm pursuing these two paths at the same time, because for me they naturally complement each other.\n\nI am neurodivergent, which is why this topic immediately became central to my work. \nI'm not dyslexic myself, but there are cases in my family.\n\nMy inspiration comes both from my own school experience, where many of my difficulties went unrecognized, and from watching my younger dyslexic cousin (Tommy!) struggle with studying. \nSeeing his real difficulties made me wish I could help him in a more concrete way, beyond just emotional support, as he studied with the help of my aunt.\n\nThe app's default color is blue, a color often associated with neurodiversity, calm, and inclusivity. It represents the idea of creating a safe and welcoming space for different ways of thinking.\n\nThe app's mascot, Leggy, was intentionally designed with a square head and a round body to symbolize coexistence and integration between different minds. The square and the circle represent two different ways of functioning, neurotypical and neurodivergent, living together, not to become the same, but to grow side by side.\n\nI strongly believe in creating tools that combine understanding, accessibility, and creativity.")
                    .font(settings.customFont(size: settings.textSize, weight: settings.boldText ? .bold : .regular))  // ← AGGIUNGI QUESTA RIGA
                    .padding(.horizontal, 40)
            }
            .navigationTitle("About Me")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    NavigationStack {
        SwiftUIView()
    }
}
