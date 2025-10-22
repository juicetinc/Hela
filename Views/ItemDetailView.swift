import SwiftUI
import CoreData
import Photos

struct ItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var item: Item
    @State private var loadedImage: UIImage?
    @State private var isEditing = false
    
    // Editable fields
    @State private var editTitle: String = ""
    @State private var editSummary: String = ""
    @State private var editQuantity: Int = 1
    @State private var editCollection: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HelaTheme.spacingXL) {
                // Image
                if let image = loadedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 400)
                        .cornerRadius(HelaTheme.cornerRadiusCard)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                } else if let imageData = item.imageData,
                          let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 400)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .frame(height: 300)
                        .overlay(
                            ProgressView()
                        )
                }
                
                // Title
                if isEditing {
                    TextField("Title", text: $editTitle)
                        .font(.title)
                        .fontWeight(.bold)
                        .textFieldStyle(.roundedBorder)
                } else {
                    if let title = item.title, !title.isEmpty {
                        Text(title)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                }
                
                // Category Badge
                if let category = item.category, !category.isEmpty {
                    Text(category.uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.blue)
                        )
                }
                
                // Summary
                if isEditing {
                    TextEditor(text: $editSummary)
                        .font(.body)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                } else {
                    if let summary = item.summary, !summary.isEmpty {
                        Text(summary)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Tags
                if let tagsCSV = item.tagsCSV, !tagsCSV.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.headline)
                        
                        FlowLayoutView(tags: tagsCSV.split(separator: ",").map(String.init))
                    }
                }
                
                // Colors
                if let colorsJSON = item.dominantColorsJSON,
                   let colorsData = colorsJSON.data(using: .utf8),
                   let colors = try? JSONDecoder().decode([String].self, from: colorsData),
                   !colors.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dominant Colors")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(colors, id: \.self) { color in
                                    Text(color)
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(.systemGray6))
                                        )
                                }
                            }
                        }
                    }
                }
                
                // Attributes
                if let attributesJSON = item.attributesJSON,
                   let attributesData = attributesJSON.data(using: .utf8),
                   let attributes = try? JSONDecoder().decode([String: AnyCodable].self, from: attributesData),
                   !attributes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Attributes")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(Array(attributes.keys.sorted()), id: \.self) { key in
                                HStack {
                                    Text(key.capitalized)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text(String(describing: attributes[key]?.value ?? ""))
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                    }
                }
                
                // Metadata
                VStack(alignment: .leading, spacing: 8) {
                    Text("Metadata")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if let createdAt = item.createdAt {
                            HStack {
                                Text("Created")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(createdAt, style: .date)
                                Text(createdAt, style: .time)
                            }
                            .font(.subheadline)
                        }
                        
                        if isEditing {
                            HStack {
                                Text("Quantity")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Stepper("\(editQuantity)", value: $editQuantity, in: 1...999)
                                    .labelsHidden()
                                Text("\(editQuantity)")
                                    .font(.subheadline)
                            }
                            .font(.subheadline)
                            
                            HStack {
                                Text("Collection")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                TextField("Collection", text: $editCollection)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(maxWidth: 150)
                            }
                            .font(.subheadline)
                        } else {
                            if item.quantity > 1 {
                                HStack {
                                    Text("Quantity")
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("\(item.quantity)")
                                }
                                .font(.subheadline)
                            }
                            
                            if let collection = item.collection, !collection.isEmpty {
                                HStack {
                                    Text("Collection")
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text(collection)
                                }
                                .font(.subheadline)
                            }
                        }
                        
                        if let imageLocalId = item.imageLocalId {
                            HStack {
                                Text("Photo Library")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("Saved")
                                    .foregroundStyle(.green)
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if isEditing {
                        saveChanges()
                    }
                    withAnimation {
                        isEditing.toggle()
                    }
                } label: {
                    Text(isEditing ? "Save" : "Edit")
                }
            }
        }
        .task {
            await loadImageFromPhotos()
        }
        .onAppear {
            loadEditState()
        }
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
    
    private func loadEditState() {
        editTitle = item.title ?? ""
        editSummary = item.summary ?? ""
        editQuantity = Int(item.quantity)
        editCollection = item.collection ?? ""
    }
    
    private func saveChanges() {
        item.title = editTitle
        item.summary = editSummary
        item.quantity = Int16(editQuantity)
        item.collection = editCollection.isEmpty ? nil : editCollection
        
        do {
            try viewContext.save()
            print("Item saved successfully")
        } catch {
            print("Error saving item: \(error)")
        }
    }
}

struct FlowLayoutView: View {
    let tags: [String]
    
    var body: some View {
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        return ZStack(alignment: .topLeading) {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: calculateHeight())
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        return ZStack(alignment: .topLeading) {
            ForEach(Array(tags.enumerated()), id: \.offset) { index, tag in
                self.item(for: tag)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { dimension in
                        if abs(width - dimension.width) > geometry.size.width {
                            width = 0
                            height -= dimension.height
                        }
                        let result = width
                        if index == tags.count - 1 {
                            width = 0
                        } else {
                            width -= dimension.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { dimension in
                        let result = height
                        if index == tags.count - 1 {
                            height = 0
                        }
                        return result
                    })
            }
        }
    }
    
    private func item(for tag: String) -> some View {
        Text(tag)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
    }
    
    private func calculateHeight() -> CGFloat {
        // Approximate height based on number of tags
        let tagWidth: CGFloat = 80
        let spacing: CGFloat = 8
        let screenWidth = UIScreen.main.bounds.width - 32
        let tagsPerRow = Int(screenWidth / (tagWidth + spacing))
        let rows = ceil(Double(tags.count) / Double(tagsPerRow))
        return CGFloat(rows) * 36
    }
}

#Preview {
    NavigationStack {
        if let item = PersistenceController.preview.container.viewContext.registeredObjects.first(where: { $0 is Item }) as? Item {
            ItemDetailView(item: item)
        } else {
            Text("No preview data")
        }
    }
}

