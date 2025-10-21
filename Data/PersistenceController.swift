import CoreData

/// Manages the Core Data stack for Hela
class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    /// Creates a preview instance with in-memory store for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Create sample items
        for i in 0..<3 {
            let newItem = Item(context: viewContext)
            newItem.id = UUID()
            newItem.createdAt = Date().addingTimeInterval(Double(-i * 86400))
            newItem.title = ["Leather Bag", "Recipe Card", "Fashion Receipt"][i]
            newItem.summary = "Sample item description"
            newItem.category = ["bag", "recipe", "receipt"][i]
            newItem.tagsCSV = "sample,test,item"
            newItem.quantity = Int16(i + 1)
        }
        
        // Create sample notes
        for i in 0..<2 {
            let newNote = NoteEntry(context: viewContext)
            newNote.id = UUID()
            newNote.createdAt = Date().addingTimeInterval(Double(-i * 43200))
            newNote.title = ["Shopping List", "Meeting Notes"][i]
            newNote.body = "Sample note content here..."
            newNote.category = ["document", "note"][i]
            newNote.tagsCSV = "sample,note"
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
    
    init(inMemory: Bool = false) {
        print("🔵 Initializing PersistenceController (inMemory: \(inMemory))")
        container = NSPersistentContainer(name: "Hela")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        print("🔵 Loading persistent stores...")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("❌ FATAL: Failed to load Core Data stack: \(error)")
                print("❌ Store description: \(description)")
                // In production, handle this error appropriately
                fatalError("Failed to load Core Data stack: \(error)")
            } else {
                print("✅ Core Data store loaded successfully")
                print("✅ Store URL: \(description.url?.absoluteString ?? "unknown")")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        print("✅ PersistenceController initialization complete")
    }
    
    /// Saves the view context if there are changes
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Error saving context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
