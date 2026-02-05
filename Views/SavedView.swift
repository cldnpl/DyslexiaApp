//
//  SavedView.swift
//  Leggy
//
//  Created by Auto on 27/01/26.
//

import SwiftUI

private struct MonthSection: Identifiable {
    let id: String
    let title: String
    let date: Date
    let items: [SavedItem]
}

struct SavedView: View {
    @Binding var selectedTab: Int
    @StateObject private var settings = AppSettings.shared
    @StateObject private var store: SavedStore = .shared
    @State private var readingPresentedHack: Bool = true

    private var sections: [MonthSection] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: store.items) { item in
            let comps = calendar.dateComponents([.year, .month], from: item.date)
            return "\(comps.year ?? 0)-\(comps.month ?? 0)"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM yyyy"

        return grouped
            .compactMap { key, items in
                guard
                    let first = items.sorted(by: { $0.date > $1.date }).first,
                    let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: first.date))
                else { return nil }
                return MonthSection(
                    id: key,
                    title: formatter.string(from: monthStart),
                    date: monthStart,
                    items: items.sorted(by: { $0.date > $1.date })
                )
            }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(sections) { section in
                    Section {
                        ForEach(section.items) { item in
                            NavigationLink(value: item) {
                                SavedCard(item: item)
                            }
                            .buttonStyle(.plain)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button {
                                    store.delete(id: item.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                        }
                    } header: {
                        Text(section.title)
                            .textCase(nil)
                            .font(settings.customFont(size: settings.textSize * 1.05, weight: .regular))
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Saved Texts")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: SavedItem.self) { item in
                ReadingView(
                    isPresented: $readingPresentedHack,
                    selectedTab: $selectedTab,
                    textToRead: item.fullText
                )
            }
        }
    }
}

private struct SavedCard: View {
    @StateObject private var settings = AppSettings.shared
    let item: SavedItem
    
    private var cardFill: Color {
        settings.isDarkMode
            ? Color(uiColor: .secondarySystemGroupedBackground)
            : Color(uiColor: .systemBackground)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .font(settings.customFont(size: settings.textSize * 2.0, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(item.preview)
                    .font(settings.customFont(size: settings.textSize * 1.05, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.trailing, 16)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color(uiColor: .separator), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
        )
    }
}

#Preview {
    SavedView(selectedTab: .constant(1))
}

