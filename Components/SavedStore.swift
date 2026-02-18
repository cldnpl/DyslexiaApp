//
//  SavedStore.swift
//  Leggy
//
//  Created by Claudia Napolitano on 27/01/26.
//

import Foundation

struct SavedItem: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var preview: String
    var fullText: String
    var date: Date

    init(
        id: UUID = UUID(),
        title: String,
        preview: String,
        fullText: String,
        date: Date
    ) {
        self.id = id
        self.title = title
        self.preview = preview
        self.fullText = fullText
        self.date = date
    }
}

@MainActor
final class SavedStore: ObservableObject {
    static let shared = SavedStore()

    @Published private(set) var items: [SavedItem] = []

    private let storageKey = "savedItems.v1"

    private init() {
        load()

        // Seed demo data solo se completamente vuoto
        if items.isEmpty {
            seedDemo()
            save()
        } else {
            // Add only specific demo data if missing (without affecting user data)
            ensureDemoData()
        }
    }

    func add(title: String, text: String, date: Date = .now) {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let preview = Self.makePreview(from: cleaned)
        let item = SavedItem(title: title, preview: preview, fullText: cleaned, date: date)
        items.insert(item, at: 0)
        save()
    }

    func delete(id: UUID) {
        items.removeAll { $0.id == id }
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            items = []
            return
        }
        do {
            items = try JSONDecoder().decode([SavedItem].self, from: data)
        } catch {
            items = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // ignora
        }
    }

    private func seedDemo() {
        let cal = Calendar.current
        
        let historyFullText = "The French Revolution was a period of radical political and social change in France that began in 1789 and lasted until 1799. It marked the end of the absolute monarchy and the rise of democracy and nationalism.\n\nKey events include the Storming of the Bastille on July 14, 1789, which became a symbol of the revolution. The Declaration of the Rights of Man and of the Citizen established fundamental rights for all citizens.\n\nThe revolution went through several phases: the National Assembly, the Reign of Terror led by Robespierre, and finally the rise of Napoleon Bonaparte. The revolution had profound effects not only in France but across Europe, inspiring movements for liberty and equality."
        
        let danishFullText = "At studere er en vigtig del af livet for mange unge mennesker. I skolen og på universitetet lærer vi ikke kun fag som matematik, historie og biologi, men også hvordan man organiserer sin tid og arbejder selvstændigt.\n\nFor at lære godt er det vigtigt at have en god metode. Nogle studerende laver noter, andre bruger farver eller små skemaer for at huske bedre. Det hjælper også at tage pauser, så hjernen kan hvile og koncentrationen ikke forsvinder.\n\nMotivation spiller en stor rolle i studiet. Når man forstår, hvorfor et fag er nyttigt, bliver det lettere at engagere sig. Desuden kan det være en god idé at studere sammen med andre, fordi man kan forklare ting til hinanden og dele forskellige synspunkter.\n\nTil sidst er det vigtigt at huske, at fejl er en del af læringsprocessen. Man lærer ikke kun af succes, men også af sine fejl."
        
        let medicalFullText = "Take one pill at the morning after breakfast, preferably with a glass of water. Do not take on an empty stomach.\n\nTake one pill in the evening before going to bed, at least two hours after dinner.\n\nImportant: Do not exceed the recommended dosage. If you miss a dose, take it as soon as you remember, but skip it if it's almost time for your next dose.\n\nSide effects may include mild dizziness or nausea. If symptoms persist or worsen, contact your doctor immediately.\n\nStore in a cool, dry place away from direct sunlight. Keep out of reach of children."
        
    
        items = [
            SavedItem(
                title: "History homework",
                preview: Self.makePreview(from: historyFullText),
                fullText: historyFullText,
                date: cal.date(from: DateComponents(year: 2026, month: 1, day: 10)) ?? .now
            ),
            SavedItem(
                title: "Danish notes",
                preview: Self.makePreview(from: danishFullText),
                fullText: danishFullText,
                date: cal.date(from: DateComponents(year: 2026, month: 1, day: 18)) ?? .now
            ),
            
            SavedItem(
                title: "Medical recipe",
                preview: Self.makePreview(from: medicalFullText),
                fullText: medicalFullText,
                date: cal.date(from: DateComponents(year: 2025, month: 12, day: 1)) ?? .now
            )
        ]
    }
    
    private func ensureDemoData() {
        // Check if demo data already exists
        let demoTitles = ["History homework", "Danish notes", "Medical recipe"]
        let hasDemoData = demoTitles.allSatisfy { title in
            items.contains(where: { $0.title == title })
        }
        
        // If all demo data already exists, do nothing
        if hasDemoData {
            return
        }
        
        // If there are user-saved texts (not demo), add only missing demo items
        let cal = Calendar.current
        
        let historyFullText = "The French Revolution was a period of radical political and social change in France that began in 1789 and lasted until 1799. It marked the end of the absolute monarchy and the rise of democracy and nationalism.\n\nKey events include the Storming of the Bastille on July 14, 1789, which became a symbol of the revolution. The Declaration of the Rights of Man and of the Citizen established fundamental rights for all citizens.\n\nThe revolution went through several phases: the National Assembly, the Reign of Terror led by Robespierre, and finally the rise of Napoleon Bonaparte. The revolution had profound effects not only in France but across Europe, inspiring movements for liberty and equality."
        
        let danishFullText = "At studere er en vigtig del af livet for mange unge mennesker. I skolen og på universitetet lærer vi ikke kun fag som matematik, historie og biologi, men også hvordan man organiserer sin tid og arbejder selvstændigt.\n\nFor at lære godt er det vigtigt at have en god metode. Nogle studerende laver noter, andre bruger farver eller små skemaer for at huske bedre. Det hjælper også at tage pauser, så hjernen kan hvile og koncentrationen ikke forsvinder.\n\nMotivation spiller en stor rolle i studiet. Når man forstår, hvorfor et fag er nyttigt, bliver det lettere at engagere sig. Desuden kan det være en god idé at studere sammen med andre, fordi man kan forklare ting til hinanden og dele forskellige synspunkter.\n\nTil sidst er det vigtigt at huske, at fejl er en del af læringsprocessen. Man lærer ikke kun af succes, men også af sine fejl."
        
        let medicalFullText = "Take one pill at the morning after breakfast, preferably with a glass of water. Do not take on an empty stomach.\n\nTake one pill in the evening before going to bed, at least two hours after dinner.\n\nImportant: Do not exceed the recommended dosage. If you miss a dose, take it as soon as you remember, but skip it if it's almost time for your next dose.\n\nSide effects may include mild dizziness or nausea. If symptoms persist or worsen, contact your doctor immediately.\n\nStore in a cool, dry place away from direct sunlight. Keep out of reach of children."
        
        let demoItems = [
            ("History homework", historyFullText, cal.date(from: DateComponents(year: 2026, month: 1, day: 10)) ?? .now),
            ("Danish notes", danishFullText, cal.date(from: DateComponents(year: 2026, month: 1, day: 18)) ?? .now),
            ("Medical recipe", medicalFullText, cal.date(from: DateComponents(year: 2025, month: 12, day: 1)) ?? .now)
        ]
        
        var hasChanges = false
        for (title, fullText, date) in demoItems {
            // Add only if no item with this title already exists
            if !items.contains(where: { $0.title == title }) {
                let item = SavedItem(
                    title: title,
                    preview: Self.makePreview(from: fullText),
                    fullText: fullText,
                    date: date
                )
                items.append(item)
                hasChanges = true
            }
        }
        
        if hasChanges {
            save()
        }
    }

    private static func makePreview(from text: String) -> String {
        let oneLine = text
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if oneLine.count <= 42 { return oneLine }
        let idx = oneLine.index(oneLine.startIndex, offsetBy: 42)
        return String(oneLine[..<idx]) + "..."
    }
    
    // Debug function to list all saved texts
    func printAllSavedItems() {
        print("=== TESTI SALVATI ===")
        print("Totale: \(items.count)")
        for (index, item) in items.enumerated() {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            print("\n[\(index + 1)] \(item.title)")
            print("   Data: \(formatter.string(from: item.date))")
            print("   Preview: \(item.preview)")
            print("   ID: \(item.id)")
        }
        print("\n====================")
    }
    
    // Function to reset all data (debug only)
    func resetAllData() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        items = []
        seedDemo()
        save()
    }
}

