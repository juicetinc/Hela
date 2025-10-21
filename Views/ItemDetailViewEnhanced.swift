import SwiftUI
import CoreData
import Photos

struct ItemDetailViewEnhanced: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var item: Item
    
    @State private var loadedImage: UIImage?
    @State private var showEdit = false
    
    private var heroImage: Image? {
        if let image = loadedImage {
            return Image(uiImage: image)
        } else if let imageData = item.imageData,
                  let uiImage = UIImage(data: imageData) {
            return Image(uiImage: uiImage)
        }
        return nil
    }
    
    private var tags: [String] {
        (item.tagsCSV ?? "").split(separator: ",").map(String.init)
    }
    
    private var attributes: [(key: String, value: String)] {
        guard let attributesJSON = item.attributesJSON,
              let attributesData = attributesJSON.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([String: AnyCodable].self, from: attributesData) else {
            return []
        }
        
        return decoded.map { (key: $0.key, value: String(describing: $0.value.value)) }
            .sorted { $0.key < $1.key }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Image
                if let heroImage = heroImage {
                    heroImage
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .frame(height: 300)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 64))
                                .foregroundStyle(.secondary)
                        )
                }
                
                // Content
                VStack(alignment: .leading, spacing: HelaTheme.spacingM) {
                    // Title
                    Text(item.title ?? item.classification ?? "Untitled")
                        .font(HelaTheme.Typography.title2)
                        .bold()
                    
                    // Summary
                    if let summary = item.summary, !summary.isEmpty {
                        Text(summary)
                            .font(HelaTheme.Typography.body)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Tags
                    if !tags.isEmpty {
                        FlowLayoutSimple(spacing: 6) {
                            ForEach(tags, id: \.self) { tag in
                                TagChip(text: tag)
                            }
                        }
                    }
                    
                    // Attributes
                    if !attributes.isEmpty {
                        Divider()
                            .padding(.vertical, 4)
                        
                        VStack(spacing: 0) {
                            ForEach(attributes, id: \.key) { kv in
                                HStack {
                                    Text(kv.key.capitalized)
                                        .font(HelaTheme.Typography.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                    
                                    Text(kv.value)
                                        .font(HelaTheme.Typography.subheadline)
                                }
                                .padding(.vertical, 6)
                                
                                if kv.key != attributes.last?.key {
                                    Divider()
                                }
                            }
                        }
                    }
                    
                    // Metadata
                    Divider()
                        .padding(.vertical, 4)
                    
                    VStack(spacing: 0) {
                        if let quantity = item.quantity, quantity > 1 {
                            metadataRow(key: "Quantity", value: "\(quantity)")
                            Divider()
                        }
                        
                        if let collection = item.collection, !collection.isEmpty {
                            metadataRow(key: "Collection", value: collection)
                            Divider()
                        }
                        
                        if let category = item.category, !category.isEmpty {
                            metadataRow(key: "Category", value: category.capitalized)
                            Divider()
                        }
                        
                        if let createdAt = item.createdAt {
                            metadataRow(key: "Created", value: createdAt.formatted(date: .abbreviated, time: .shortened))
                        }
                    }
                }
                .padding(HelaTheme.spacingL)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showEdit = true
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            ItemDetailView(item: item)
        }
        .task {
            await loadImageFromPhotos()
        }
    }
    
    private func metadataRow(key: String, value: String) -> some View {
        HStack {
            Text(key)
                .font(HelaTheme.Typography.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(HelaTheme.Typography.subheadline)
        }
        .padding(.vertical, 6)
    }
    
    private func loadImageFromPhotos() async {
        guard let imageLocalId = item.imageLocalId else { return }
        
        guard let asset = PhotoLibraryService.shared.getAsset(from: imageLocalId) else {
            return
        }
        
        if let image = await PhotoLibraryService.shared.loadImage(from: asset) {
            await MainActor.run {
                self.loadedImage = image
            }
        }
    }
}

#Preview {
    NavigationStack {
        if let item = PersistenceController.preview.container.viewContext.registeredObjects.first(where: { $0 is Item }) as? Item {
            ItemDetailViewEnhanced(item: item)
        } else {
            Text("No preview data")
        }
    }
}

