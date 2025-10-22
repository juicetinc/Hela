import UIKit
import CoreData

/// Data layer service for managing inventory items and notes
class InventoryStore {
    static let shared = InventoryStore()
    
    private init() {}
    
    // MARK: - Item Management
    
    /// Saves a new item to the Core Data store with full details
    /// - Parameters:
    ///   - image: The UIImage to save
    ///   - itemRecord: The ItemRecord with classification details
    ///   - visionSummary: The VisionSummary with vision analysis
    ///   - imageLocalId: The Photos library local identifier
    ///   - collection: Optional collection name
    ///   - quantity: Item quantity (default 1)
    ///   - context: The managed object context to use
    /// - Returns: The created Item object
    @discardableResult
    func saveItem(
        image: UIImage,
        itemRecord: ItemRecord,
        visionSummary: VisionSummary,
        imageLocalId: String?,
        collection: String? = nil,
        quantity: Int16 = 1,
        context: NSManagedObjectContext
    ) -> Item {
        let newItem = Item(context: context)
        newItem.id = UUID()
        newItem.createdAt = Date()
        
        // ItemRecord fields
        newItem.title = itemRecord.title
        newItem.summary = itemRecord.summary
        newItem.category = itemRecord.category
        newItem.classification = itemRecord.title // Legacy field
        
        // Collection and quantity
        newItem.collection = collection
        newItem.quantity = quantity
        
        // Store tags as CSV
        newItem.tagsCSV = itemRecord.tags.joined(separator: ",")
        
        // Store OCR text
        newItem.ocrText = visionSummary.ocrText
        
        // Store colors as JSON
        if let colorsData = try? JSONEncoder().encode(visionSummary.colors),
           let colorsJSON = String(data: colorsData, encoding: .utf8) {
            newItem.dominantColorsJSON = colorsJSON
        }
        
        // Store attributes as JSON
        if let attributesData = try? JSONEncoder().encode(itemRecord.attributes),
           let attributesJSON = String(data: attributesData, encoding: .utf8) {
            newItem.attributesJSON = attributesJSON
        }
        
        // Store Photos library identifier
        newItem.imageLocalId = imageLocalId
        
        // Compress and save image data
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            newItem.imageData = imageData
        }
        
        // Save on the context's own queue to avoid threading issues
        do {
            try context.save()
            print("✅ Item saved successfully: \(itemRecord.title)")
        } catch {
            print("❌ Error saving item: \(error)")
            // Log more details about the error
            if let nsError = error as NSError? {
                print("Error details: \(nsError.userInfo)")
            }
        }
        
        return newItem
    }
    
    /// Legacy save method for backward compatibility
    @discardableResult
    func saveItem(
        image: UIImage,
        classification: String,
        notes: String? = nil,
        context: NSManagedObjectContext
    ) -> Item {
        let newItem = Item(context: context)
        newItem.id = UUID()
        newItem.createdAt = Date()
        newItem.classification = classification
        newItem.title = classification
        newItem.notes = notes
        newItem.quantity = 1
        
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            newItem.imageData = imageData
        }
        
        do {
            try context.save()
            print("Item saved successfully: \(classification)")
        } catch {
            print("Error saving item: \(error)")
        }
        
        return newItem
    }
    
    /// Fetches all items from the store
    func fetchAllItems(context: NSManagedObjectContext) -> [Item] {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Item.createdAt, ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching items: \(error)")
            return []
        }
    }
    
    /// Fetches items filtered by category
    func fetchItems(byCategory category: String, context: NSManagedObjectContext) -> [Item] {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", category)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Item.createdAt, ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching items by category: \(error)")
            return []
        }
    }
    
    /// Fetches items filtered by collection
    func fetchItems(inCollection collection: String, context: NSManagedObjectContext) -> [Item] {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "collection == %@", collection)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Item.createdAt, ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching items by collection: \(error)")
            return []
        }
    }
    
    /// Deletes an item from the store
    func deleteItem(_ item: Item, context: NSManagedObjectContext) {
        context.delete(item)
        
        do {
            try context.save()
            print("Item deleted successfully")
        } catch {
            print("Error deleting item: \(error)")
        }
    }
    
    // MARK: - Note Management
    
    /// Saves a new note entry
    @discardableResult
    func saveNote(
        title: String,
        body: String,
        category: String,
        tags: [String],
        attributes: [String: AnyCodable],
        context: NSManagedObjectContext
    ) -> NoteEntry {
        let newNote = NoteEntry(context: context)
        newNote.id = UUID()
        newNote.createdAt = Date()
        newNote.title = title
        newNote.body = body
        newNote.category = category
        newNote.tagsCSV = tags.joined(separator: ",")
        
        if let attributesData = try? JSONEncoder().encode(attributes),
           let attributesJSON = String(data: attributesData, encoding: .utf8) {
            newNote.attributesJSON = attributesJSON
        }
        
        do {
            try context.save()
            print("Note saved successfully: \(title)")
        } catch {
            print("Error saving note: \(error)")
        }
        
        return newNote
    }
    
    /// Fetches all notes from the store
    func fetchAllNotes(context: NSManagedObjectContext) -> [NoteEntry] {
        let fetchRequest: NSFetchRequest<NoteEntry> = NoteEntry.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \NoteEntry.createdAt, ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching notes: \(error)")
            return []
        }
    }
    
    /// Deletes a note from the store
    func deleteNote(_ note: NoteEntry, context: NSManagedObjectContext) {
        context.delete(note)
        
        do {
            try context.save()
            print("Note deleted successfully")
        } catch {
            print("Error deleting note: \(error)")
        }
    }
    
    // MARK: - Utility
    
    /// Returns the total count of items
    func itemCount(context: NSManagedObjectContext) -> Int {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        
        do {
            return try context.count(for: fetchRequest)
        } catch {
            print("Error counting items: \(error)")
            return 0
        }
    }
    
    /// Returns the total count of notes
    func noteCount(context: NSManagedObjectContext) -> Int {
        let fetchRequest: NSFetchRequest<NoteEntry> = NoteEntry.fetchRequest()
        
        do {
            return try context.count(for: fetchRequest)
        } catch {
            print("Error counting notes: \(error)")
            return 0
        }
    }
}

