import SwiftUI
import CoreData
import Photos

struct CollectionsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.createdAt, ascending: false)],
        animation: .default)
    private var allItems: FetchedResults<Item>
    
    @State private var showingImportSheet = false
    
    // Group items by collection
    private var collectionGroups: [(name: String, count: Int)] {
        let grouped = Dictionary(grouping: allItems.filter { $0.collection != nil }) { $0.collection! }
        return grouped.map { (name: $0.key, count: $0.value.count) }
            .sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Import section
                Section {
                    Button {
                        showingImportSheet = true
                    } label: {
                        Label("Import from Photos Album", systemImage: "photo.on.rectangle.angled")
                            .foregroundStyle(.blue)
                    }
                }
                
                // Collections section
                Section {
                    if collectionGroups.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "folder")
                                .font(.system(size: 64))
                                .foregroundStyle(.secondary)
                            
                            Text("No Collections")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Collections will appear here when you organize your items")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(40)
                    } else {
                        ForEach(collectionGroups, id: \.name) { collection in
                            NavigationLink {
                                CollectionDetailView(collectionName: collection.name)
                            } label: {
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .foregroundStyle(.purple)
                                        .font(.title3)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(collection.name)
                                            .font(.headline)
                                        
                                        Text("\(collection.count) item\(collection.count == 1 ? "" : "s")")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(collection.count)")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                } header: {
                    Text("Collections")
                }
            }
            .navigationTitle("Collections")
            .sheet(isPresented: $showingImportSheet) {
                PhotoAlbumImportView()
            }
        }
    }
}

struct CollectionDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var items: FetchedResults<Item>
    
    let collectionName: String
    
    init(collectionName: String) {
        self.collectionName = collectionName
        _items = FetchRequest(
            entity: Item.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Item.createdAt, ascending: false)],
            predicate: NSPredicate(format: "collection == %@", collectionName),
            animation: .default
        )
    }
    
    var body: some View {
        List {
            ForEach(items, id: \.objectID) { item in
                NavigationLink {
                    ItemDetailView(item: item)
                } label: {
                    ItemRow(item: item)
                }
            }
        }
        .navigationTitle(collectionName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PhotoAlbumImportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var albums: [PHAssetCollection] = []
    @State private var selectedAlbum: PHAssetCollection?
    @State private var collectionName = ""
    @State private var isImporting = false
    @State private var importProgress: Double = 0
    @State private var importedCount = 0
    @State private var totalCount = 0
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Select Album", selection: $selectedAlbum) {
                        Text("Choose an album...").tag(nil as PHAssetCollection?)
                        ForEach(albums, id: \.localIdentifier) { album in
                            Text(album.localizedTitle ?? "Unknown")
                                .tag(album as PHAssetCollection?)
                        }
                    }
                } header: {
                    Text("Photos Album")
                }
                
                Section {
                    TextField("Collection name", text: $collectionName)
                } header: {
                    Text("Save to Collection")
                } footer: {
                    Text("All imported items will be saved to this collection")
                }
                
                if isImporting {
                    Section {
                        VStack(spacing: 12) {
                            ProgressView(value: importProgress, total: 1.0)
                            
                            Text("Importing \(importedCount) of \(totalCount)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Import from Album")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isImporting)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Import") {
                        Task {
                            await importAlbum()
                        }
                    }
                    .disabled(selectedAlbum == nil || collectionName.isEmpty || isImporting)
                }
            }
            .alert("Import Complete", isPresented: $showingSuccess) {
                Button("Done") {
                    dismiss()
                }
            } message: {
                Text("Imported \(importedCount) items successfully")
            }
            .task {
                await loadAlbums()
            }
        }
    }
    
    private func loadAlbums() async {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        guard status == .authorized || status == .limited else {
            return
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: true)]
        
        let userAlbums = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .any,
            options: fetchOptions
        )
        
        var loadedAlbums: [PHAssetCollection] = []
        userAlbums.enumerateObjects { collection, _, _ in
            loadedAlbums.append(collection)
        }
        
        await MainActor.run {
            self.albums = loadedAlbums
        }
    }
    
    private func importAlbum() async {
        guard let album = selectedAlbum else { return }
        
        await MainActor.run {
            isImporting = true
            importProgress = 0
            importedCount = 0
        }
        
        // Fetch assets from album
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAssetCollection.fetchAssets(in: album, options: fetchOptions)
        
        await MainActor.run {
            totalCount = assets.count
        }
        
        // Import each asset
        for index in 0..<assets.count {
            let asset = assets[index]
            
            // Load image
            if let image = await PhotoLibraryService.shared.loadImage(from: asset) {
                // Process with Vision and AI
                do {
                    let visionSummary = try await VisionAnalyzer.shared.analyze(image: image)
                    let itemRecord = try await AIClassifier().classify(from: visionSummary, userHint: nil)
                    
                    // Save to Core Data
                    await MainActor.run {
                        _ = InventoryStore.shared.saveItem(
                            image: image,
                            itemRecord: itemRecord,
                            visionSummary: visionSummary,
                            imageLocalId: asset.localIdentifier,
                            collection: collectionName,
                            quantity: 1,
                            context: viewContext
                        )
                        
                        importedCount += 1
                        importProgress = Double(importedCount) / Double(totalCount)
                    }
                } catch {
                    print("Error processing asset: \(error)")
                }
            }
        }
        
        await MainActor.run {
            isImporting = false
            showingSuccess = true
        }
    }
}

// Extension to make PHAssetCollection identifiable
extension PHAssetCollection: @retroactive Identifiable {
    public var id: String {
        return localIdentifier
    }
}

#Preview {
    CollectionsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

