import Foundation

struct ItemRecord: Codable {
    var title: String
    var summary: String
    var category: String
    var tags: [String]
    var attributes: [String: AnyCodable]
    
    /// Valid categories for Hela items
    static let validCategories = [
        "general", "bag", "recipe", "receipt", "fashion",
        "decor", "document", "note"
    ]
}
