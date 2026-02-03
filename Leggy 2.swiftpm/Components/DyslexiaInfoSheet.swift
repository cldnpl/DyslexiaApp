//
//  DyslexiaInfoSheet.swift
//  Leggy
//
//  Created by Claudia Napolitano on 29/01/26.
//

import SwiftUI

struct DyslexiaInfoSheet: View {
    @StateObject private var settings = AppSettings.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
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
                    
                    sectionTitle("Early School Years (Ages 5–7)")
                    bulletItem("Letter-Sound Mapping: Struggling to learn that letters represent specific sounds (the \"alphabetic principle\").")
                    bulletItem("Phonemic Awareness: Difficulty breaking words down into individual sounds (e.g., realizing \"cat\" is made of /c/, /a/, and /t/).")
                    bulletItem("Consistent Inversions: Frequently confusing letters that look similar, such as b and d, p and q, or m and w.")
                    bulletItem("Slow Decoding: Taking a long time to read even simple, high-frequency words.")
                    
                    sectionTitle("Later Primary School (Ages 8–12)")
                    bulletItem("Avoidance: Showing a strong dislike for reading aloud or an active avoidance of reading-based tasks.")
                    bulletItem("Spelling Inconsistency: Spelling the same word differently in the same paragraph.")
                    bulletItem("Slow Reading Rate: Reading significantly slower than peers, often losing the sense of what is being read due to the effort of decoding.")
                    bulletItem("Word Substitutions: Substituting words with similar meanings but different sounds (e.g., saying \"house\" instead of \"home\").")
                    
                    sectionTitle("Secondary School and Beyond")
                    bulletItem("Cognitive Fatigue: Becoming unusually tired after reading or writing tasks due to the high mental effort required.")
                    bulletItem("Poor Note-Taking: Difficulty listening to a lecture and writing notes at the same time.")
                    bulletItem("Time Management: Struggling to estimate how long a reading or writing assignment will take to complete.")
                }
                .padding()
            }
            .navigationTitle("Identifying Dyslexia")
        }
    }
    
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(settings.customFont(size: settings.textSize * 1.1, weight: .bold))
            .padding(.top, 12)
    }
    
    private func bulletItem(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(settings.customFont(size: settings.textSize, weight: settings.boldText ? .bold : .regular))
            Text(text)
                .font(settings.customFont(size: settings.textSize, weight: settings.boldText ? .bold : .regular))
        }
    }
}
#Preview {
    DyslexiaInfoSheet()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
}
