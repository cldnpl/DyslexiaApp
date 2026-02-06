//
//  DyslexiaInfoSheet.swift
//  Leggy
//
//  Created by Claudia Napolitano on 29/01/26.
//

import SwiftUI

struct DyslexiaInfoSheet: View {
    @StateObject private var settings = AppSettings.shared
    @State private var expandedSections: Set<String> = []
    
    private let sections: [DyslexiaSection] = [
        DyslexiaSection(
            title: "Early School Years (Ages 5–7)",
            bullets: [
                "Letter-Sound Mapping: Struggling to learn that letters represent specific sounds (the \"alphabetic principle\").",
                "Phonemic Awareness: Difficulty breaking words down into individual sounds (e.g., realizing \"cat\" is made of /c/, /a/, and /t/).",
                "Consistent Inversions: Frequently confusing letters that look similar, such as b and d, p and q, or m and w.",
                "Slow Decoding: Taking a long time to read even simple, high-frequency words."
            ]
        ),
        DyslexiaSection(
            title: "Later Primary School (Ages 8–12)",
            bullets: [
                "Avoidance: Showing a strong dislike for reading aloud or an active avoidance of reading-based tasks.",
                "Spelling Inconsistency: Spelling the same word differently in the same paragraph.",
                "Slow Reading Rate: Reading significantly slower than peers, often losing the sense of what is being read due to the effort of decoding.",
                "Word Substitutions: Substituting words with similar meanings but different sounds (e.g., saying \"house\" instead of \"home\")."
            ]
        ),
        DyslexiaSection(
            title: "Secondary School and Beyond",
            bullets: [
                "Cognitive Fatigue: Becoming unusually tired after reading or writing tasks due to the high mental effort required.",
                "Poor Note-Taking: Difficulty listening to a lecture and writing notes at the same time.",
                "Time Management: Struggling to estimate how long a reading or writing assignment will take to complete."
            ]
        )
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(sections) { section in
                        DisclosureGroup(
                            isExpanded: Binding(
                                get: { expandedSections.contains(section.title) },
                                set: { isExpanded in
                                    if isExpanded {
                                        expandedSections.insert(section.title)
                                    } else {
                                        expandedSections.remove(section.title)
                                    }
                                }
                            )
                        ) {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(section.bullets, id: \.self) { bullet in
                                    bulletItem(bullet)
                                }
                            }
                            .padding(.top, 8)
                        } label: {
                            Text(section.title)
                                .font(settings.customFont(size: settings.textSize * 1.1, weight: .bold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                                .truncationMode(.tail)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(uiColor: .separator).opacity(0.6), lineWidth: 1)
                        )
                    }
                    
                    // Immagine di Leggy con il libro
                    HStack {
                        Spacer()
                        Image("bookLeggy")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                }
                .padding()
            }
            .navigationTitle("Identifying Dyslexia")
        }
        .presentationDetents([UIDevice.current.userInterfaceIdiom == .pad ? .large : .fraction(0.7)])
        .presentationDragIndicator(.visible)
    }
    
    private func bulletItem(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(settings.customFont(size: settings.textSize, weight: settings.boldText ? .bold : .regular))
            bulletText(text)
        }
    }

    @ViewBuilder
    private func bulletText(_ text: String) -> some View {
        let regularFont = settings.customFont(size: settings.textSize, weight: settings.boldText ? .bold : .regular)
        let boldFont = settings.customFont(size: settings.textSize, weight: .bold)
        let parts = text.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
        if parts.count == 2 {
            let subtitle = String(parts[0]).trimmingCharacters(in: .whitespaces)
            let body = String(parts[1]).trimmingCharacters(in: .whitespaces)
            Text(subtitle + ": ")
                .font(boldFont)
            + Text(body)
                .font(regularFont)
        } else {
            Text(text)
                .font(regularFont)
        }
    }
}

private struct DyslexiaSection: Identifiable {
    let id = UUID()
    let title: String
    let bullets: [String]
}
#Preview {
    DyslexiaInfoSheet()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
}
