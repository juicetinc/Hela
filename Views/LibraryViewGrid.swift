import SwiftUI
import CoreData
import Photos

struct LibraryViewGrid: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.createdAt, ascending: false)],
        animation: .default)
    private var allItems: FetchedResults<Item>
    
    @State private var searchText = ""
    @State private var showFilters = false
    @State private var selectedCategory = "All"
    @State private var selectedCollection = "All"
    @State private var sortBy = "Newest"
    @State private var showingUnifiedSearch = false
    
    // Computed property for unique collections
    private var collections: [String] {
        let uniqueCollections = Set(allItems.compactMap { $0.collection }).sorted()
        return ["All"] + uniqueCollections
    }
    
    private var filteredAndSortedItems: [Item] {
        var items = Array(allItems)
        
        // Filter by category
        if selectedCategory != "All" {
            items = items.filter { $0.category?.lowercased() == selectedCategory.lowercased() }
        }
        
        // Filter by collection
        if selectedCollection != "All" {
            items = items.filter { $0.collection == selectedCollection }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            let searchLower = searchText.lowercased()
            items = items.filter { item in
                item.title?.lowercased().contains(searchLower) == true ||
                item.summary?.lowercased().contains(searchLower) == true ||
                item.tagsCSV?.lowercased().contains(searchLower) == true ||
                item.ocrText?.lowercased().contains(searchLower) == true
            }
        }
        
        // Sort
        switch sortBy {
        case "Newest":
            items.sort { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }
        case "A–Z":
            items.sort { ($0.title ?? "") < ($1.title ?? "") }
        case "Most Qty":
            items.sort { $0.quantity > $1.quantity }
        default:
            break
        }
        
        return items
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Debug indicator
                Text("📚 LibraryViewGrid - Items: \(allItems.count)")
                    .font(.caption)
                    .padding(4)
                    .background(Color.green.opacity(0.3))
                
                Group {
                    if filteredAndSortedItems.isEmpty {
                        emptyState
                } else {
                    ScrollView {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 160), spacing: 12)],
                            spacing: 12
                        ) {
                            ForEach(filteredAndSortedItems, id: \.objectID) { item in
                                NavigationLink {
                                    ItemDetailViewEnhanced(item: item)
                                } label: {
                                    ItemGridCell(
                                        image: itemImage(for: item),
                                        title: item.title ?? item.classification ?? "Untitled",
                                        tags: (item.tagsCSV ?? "").split(separator: ",").map(String.init),
                                        quantity: Int(item.quantity)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                    }
                }
                }
            }
            .navigationTitle("Hela")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingUnifiedSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass.circle")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilters.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterSheet(
                    selectedCategory: $selectedCategory,
                    selectedCollection: $selectedCollection,
                    sortBy: $sortBy,
                    collections: collections
                )
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showingUnifiedSearch) {
                UnifiedSearchView()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: HelaTheme.spacingL) {
            Image(systemName: searchText.isEmpty ? "photo.stack" : "magnifyingglass")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
            Text(searchText.isEmpty ? "No Items" : "No Results")
                .font(HelaTheme.Typography.title2)
                .fontWeight(.semibold)
            
            Text(searchText.isEmpty ? "Capture items to see them here" : "Try a different search or filter")
                .font(HelaTheme.Typography.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(HelaTheme.spacingXL)
    }
    
    private func itemImage(for item: Item) -> Image? {
        // Try to load from imageData first (for quick preview)
        if let imageData = item.imageData,
           let uiImage = UIImage(data: imageData) {
            return Image(uiImage: uiImage)
        }
        
        // Fallback to placeholder
        return nil
    }
}

#Preview {
    LibraryViewGrid()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

