import SwiftUI
import CoreData
import Photos

struct LibraryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var searchText = ""
    @State private var selectedCategory = "all"
    @State private var selectedCollection = "all"
    @State private var parsedFilters: [String: String] = [:]
    @State private var ftsQuery: String = ""
    @State private var showingUnifiedSearch = false
    
    // Dynamic fetch request based on filters
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.createdAt, ascending: false)],
        animation: .default)
    private var allItems: FetchedResults<Item>
    
    private let categories = ["all", "general", "bag", "recipe", "receipt", "fashion", "decor", "document", "note"]
    
    // Computed property for unique collections
    private var collections: [String] {
        let uniqueCollections = Set(allItems.compactMap { $0.collection }).sorted()
        return ["all"] + uniqueCollections
    }
    
    var filteredItems: [Item] {
        var items = Array(allItems)
        
        // Filter by category
        if selectedCategory != "all" {
            items = items.filter { item in
                item.category?.lowercased() == selectedCategory
            }
        }
        
        // Filter by collection
        if selectedCollection != "all" {
            items = items.filter { item in
                item.collection == selectedCollection
            }
        }
        
        // Filter by search text (with natural language support)
        if !searchText.isEmpty {
            // Check if search query looks like natural language (has multiple words or specific keywords)
            let isNaturalLanguage = searchText.contains(" ") || 
                                   searchText.lowercased().contains("with") ||
                                   searchText.lowercased().contains("and")
            
            if isNaturalLanguage {
                // Use QueryPlanner for natural language queries
                items = filterWithNaturalLanguage(items: items, query: searchText)
            } else {
                // Use simple keyword search
                items = items.filter { item in
                    let searchLower = searchText.lowercased()
                    
                    // Search in title
                    if let title = item.title, title.lowercased().contains(searchLower) {
                        return true
                    }
                    
                    // Search in summary
                    if let summary = item.summary, summary.lowercased().contains(searchLower) {
                        return true
                    }
                    
                    // Search in tags
                    if let tagsCSV = item.tagsCSV, tagsCSV.lowercased().contains(searchLower) {
                        return true
                    }
                    
                    // Search in OCR text
                    if let ocrText = item.ocrText, ocrText.lowercased().contains(searchLower) {
                        return true
                    }
                    
                    return false
                }
            }
        }
        
        return items
    }
    
    private func filterWithNaturalLanguage(items: [Item], query: String) -> [Item] {
        var filtered = items
        
        // Apply parsed category filter
        if let category = parsedFilters["category"] {
            filtered = filtered.filter { $0.category?.lowercased() == category }
        }
        
        // Apply color filter
        if let color = parsedFilters["color"] {
            filtered = filtered.filter { item in
                item.dominantColorsJSON?.lowercased().contains(color) == true
            }
        }
        
        // Apply pattern filter
        if let pattern = parsedFilters["pattern"] {
            filtered = filtered.filter { item in
                item.attributesJSON?.lowercased().contains(pattern) == true ||
                item.tagsCSV?.lowercased().contains(pattern) == true
            }
        }
        
        // Apply material filter
        if let material = parsedFilters["material"] {
            filtered = filtered.filter { item in
                item.attributesJSON?.lowercased().contains(material) == true
            }
        }
        
        // Apply full-text search
        if !ftsQuery.isEmpty {
            filtered = filtered.filter { item in
                item.title?.lowercased().contains(ftsQuery.lowercased()) == true ||
                item.summary?.lowercased().contains(ftsQuery.lowercased()) == true ||
                item.tagsCSV?.lowercased().contains(ftsQuery.lowercased()) == true ||
                item.ocrText?.lowercased().contains(ftsQuery.lowercased()) == true
            }
        }
        
        return filtered
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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Debug info
                Text("Items: \(allItems.count)")
                    .font(.caption)
                    .padding(4)
                    .background(Color.yellow)
                
                Text("Filtered: \(filteredItems.count)")
                    .font(.caption)
                    .padding(4)
                    .background(Color.orange)
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            Button {
                                withAnimation {
                                    selectedCategory = category
                                }
                            } label: {
                                Text(category.capitalized)
                                    .font(HelaTheme.Typography.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, HelaTheme.spacingL)
                                    .padding(.vertical, HelaTheme.spacingS)
                                    .background(
                                        Capsule()
                                            .fill(selectedCategory == category ? HelaTheme.Colors.primaryBlue : HelaTheme.Colors.backgroundSecondary)
                                    )
                                    .foregroundStyle(selectedCategory == category ? .white : HelaTheme.Colors.textPrimary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color(.systemBackground))
                
                // Collection filter
                if collections.count > 1 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(collections, id: \.self) { collection in
                                Button {
                                    withAnimation {
                                        selectedCollection = collection
                                    }
                                } label: {
                                    HStack(spacing: HelaTheme.spacingXS) {
                                        Image(systemName: HelaTheme.Icons.folder)
                                            .font(.system(size: 12))
                                        Text(collection.capitalized)
                                    }
                                    .font(HelaTheme.Typography.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, HelaTheme.spacingL)
                                    .padding(.vertical, HelaTheme.spacingS)
                                    .background(
                                        Capsule()
                                            .fill(selectedCollection == collection ? HelaTheme.Colors.collectionAccent : HelaTheme.Colors.backgroundSecondary)
                                    )
                                    .foregroundStyle(selectedCollection == collection ? .white : HelaTheme.Colors.textPrimary)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .background(Color(.systemBackground))
                }
                
                Divider()
                
                // Items list
                if filteredItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: searchText.isEmpty ? "photo.stack" : "magnifyingglass")
                            .font(.system(size: 64))
                            .foregroundStyle(.secondary)
                        
                        Text(searchText.isEmpty ? "No Items" : "No Results")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(searchText.isEmpty ? "Capture items to see them here" : "Try a different search or filter")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    List {
                        ForEach(filteredItems, id: \.objectID) { item in
                            NavigationLink {
                                ItemDetailView(item: item)
                            } label: {
                                ItemRow(item: item)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Library")
            .searchable(text: $searchText, prompt: "Search items...")
            .onChange(of: searchText) { _, newValue in
                if newValue.contains(" ") || newValue.lowercased().contains("with") || newValue.lowercased().contains("and") {
                    parseSearchQuery(newValue)
                } else {
                    // Clear parsed filters for simple searches
                    parsedFilters = [:]
                    ftsQuery = ""
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingUnifiedSearch = true
                    } label: {
                        Label("Search All", systemImage: "magnifyingglass.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingUnifiedSearch) {
                UnifiedSearchView()
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredItems[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting items: \(error)")
            }
        }
    }
}

struct ItemRow: View {
    @ObservedObject var item: Item
    @State private var thumbnailImage: UIImage?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Thumbnail
            Group {
                if let image = thumbnailImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else if let imageData = item.imageData,
                          let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .overlay(
                            ProgressView()
                                .controlSize(.small)
                        )
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: HelaTheme.cornerRadiusChip))
            
            // Content
            VStack(alignment: .leading, spacing: HelaTheme.spacingS) {
                // Title
                if let title = item.title, !title.isEmpty {
                    Text(title)
                        .font(.headline)
                        .lineLimit(2)
                } else if let classification = item.classification {
                    Text(classification)
                        .font(.headline)
                        .lineLimit(2)
                }
                
                // Summary
                if let summary = item.summary, !summary.isEmpty {
                    Text(summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                // Tags chips
                if let tagsCSV = item.tagsCSV, !tagsCSV.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            // Category badge
                            if let category = item.category, !category.isEmpty {
                                Text(category.uppercased())
                                    .font(.system(size: 10))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill(Color.blue)
                                    )
                            }
                            
                            // First 3 tags
                            ForEach(Array(tagsCSV.split(separator: ",").prefix(3)), id: \.self) { tag in
                                Text(String(tag))
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill(Color(.systemGray6))
                                    )
                            }
                        }
                    }
                }
                
                // Timestamp
                if let createdAt = item.createdAt {
                    Text(createdAt, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
        .task {
            await loadThumbnail()
        }
    }
    
    private func loadThumbnail() async {
        guard let imageLocalId = item.imageLocalId else { return }
        
        guard let asset = PhotoLibraryService.shared.getAsset(from: imageLocalId) else {
            return
        }
        
        // Load smaller thumbnail for list view
        let image = await loadThumbnailImage(from: asset)
        
        await MainActor.run {
            self.thumbnailImage = image
        }
    }
    
    private func loadThumbnailImage(from asset: PHAsset) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic
            options.isSynchronous = false
            options.resizeMode = .fast
            
            let targetSize = CGSize(width: 160, height: 160) // 2x for retina
            
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}

#Preview {
    LibraryView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
