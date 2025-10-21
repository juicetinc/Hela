import Foundation
import CoreData

/// Unified search result that can represent either an Item or a NoteEntry
enum SearchResult: Identifiable {
    case item(Item)
    case note(NoteEntry)
    
    var id: String {
        switch self {
        case .item(let item):
            return "item-\(item.objectID.uriRepresentation().absoluteString)"
        case .note(let note):
            return "note-\(note.objectID.uriRepresentation().absoluteString)"
        }
    }
    
    var title: String {
        switch self {
        case .item(let item):
            return item.title ?? item.classification ?? "Untitled"
        case .note(let note):
            return note.title ?? "Untitled Note"
        }
    }
    
    var subtitle: String? {
        switch self {
        case .item(let item):
            return item.summary
        case .note(let note):
            return note.body
        }
    }
    
    var category: String? {
        switch self {
        case .item(let item):
            return item.category
        case .note(let note):
            return note.category
        }
    }
    
    var createdAt: Date? {
        switch self {
        case .item(let item):
            return item.createdAt
        case .note(let note):
            return note.createdAt
        }
    }
    
    var icon: String {
        switch self {
        case .item:
            return "📷"
        case .note:
            return "📝"
        }
    }
    
    var iconSystemName: String {
        switch self {
        case .item:
            return "photo"
        case .note:
            return "note.text"
        }
    }
}

