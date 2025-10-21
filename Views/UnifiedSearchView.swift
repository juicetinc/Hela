import SwiftUI
import CoreData

struct UnifiedSearchView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.createdAt, ascending: false)],
        animation: .default)
    private var allItems: FetchedResults<Item>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \NoteEntry.createdAt, ascending: false)],
        animation: .default)
    private var allNotes: FetchedResults<NoteEntry>
    
    @State private var searchText = ""
    @State private var parsedFilters: [String: String] = [:]
    @State private var ftsQuery: String = ""
    
    private var searchResults: [SearchResult] {
        guard !searchText.isEmpty else {
            // Return recent items and notes when no search query
            let recentItems = Array(allItems.prefix(10)).map { SearchResult.item($0) }
            let recentNotes = Array(allNotes.prefix(10)).map { SearchResult.note($0) }
            return (recentItems + recentNotes).sorted { result1, result2 in
                (result1.createdAt ?? Date.distantPast) > (result2.createdAt ?? Date.distantPast)
            }
        }
        
        let searchLower = searchText.lowercased()
        
        // Search items
        let matchingItems = allItems.filter { item in
            item.title?.lowercased().contains(searchLower) == true ||
            item.summary?.lowercased().contains(searchLower) == true ||
            item.tagsCSV?.lowercased().contains(searchLower) == true ||
            item.ocrText?.lowercased().contains(searchLower) == true ||
            item.category?.lowercased().contains(searchLower) == true
        }.map { SearchResult.item($0) }
        
        // Search notes
        let matchingNotes = allNotes.filter { note in
            note.title?.lowercased().contains(searchLower) == true ||
            note.body?.lowercased().contains(searchLower) == true ||
            note.tagsCSV?.lowercased().contains(searchLower) == true ||
            note.category?.lowercased().contains(searchLower) == true
        }.map { SearchResult.note($0) }
        
        // Combine and sort by relevance/date
        return (matchingItems + matchingNotes).sorted { result1, result2 in
            (result1.createdAt ?? Date.distantPast) > (result2.createdAt ?? Date.distantPast)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if searchResults.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 64))
                            .foregroundStyle(.secondary)
                        
                        Text(searchText.isEmpty ? "Start Searching" : "No Results")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(searchText.isEmpty ? 
                            "Search across your items and notes" : 
                            "Try a different search term")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    ForEach(searchResults) { result in
                        switch result {
                        case .item(let item):
                            NavigationLink {
                                ItemDetailView(item: item)
                            } label: {
                                SearchResultRow(result: result)
                            }
                            
                        case .note(let note):
                            NavigationLink {
                                NoteDetailView(note: note)
                            } label: {
                                SearchResultRow(result: result)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $searchText, prompt: "Search items and notes...")
            .onChange(of: searchText) { _, newValue in
                if newValue.contains(" ") || newValue.lowercased().contains("with") || newValue.lowercased().contains("and") {
                    parseSearchQuery(newValue)
                }
            }
        }
    }
    
    private func parseSearchQuery(_ query: String) {
        Task {
            let (fts, filters) = await QueryPlanner.shared.plan(userQuery: query)
            await MainActor.run {
                self.ftsQuery = fts
                self.parsedFilters = filters
            }
        }
    }
}

struct SearchResultRow: View {
    let result: SearchResult
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon/Type indicator
            ZStack {
                Circle()
                    .fill(result.iconSystemName == "photo" ? Color.blue.opacity(0.1) : Color.purple.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: result.iconSystemName)
                    .font(.title3)
                    .foregroundStyle(result.iconSystemName == "photo" ? .blue : .purple)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(result.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    // Type emoji
                    Text(result.icon)
                        .font(.caption)
                }
                
                if let subtitle = result.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    if let category = result.category, !category.isEmpty {
                        Text(category.uppercased())
                            .font(.system(size: 10))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(result.iconSystemName == "photo" ? Color.blue : Color.purple)
                            )
                    }
                    
                    Spacer()
                    
                    if let createdAt = result.createdAt {
                        Text(createdAt, style: .relative)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    UnifiedSearchView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

