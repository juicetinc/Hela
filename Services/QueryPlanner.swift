import Foundation

/// Query planner that converts natural language queries into structured filters
class QueryPlanner {
    static let shared = QueryPlanner()
    
    private init() {}
    
    /// Plans a query by parsing natural language into filters and full-text search
    /// - Parameter userQuery: The natural language query from the user
    /// - Returns: A tuple of (fts: full-text search string, filters: structured filters)
    func plan(userQuery: String) async -> (fts: String, filters: [String: String]) {
        let query = userQuery.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        var filters: [String: String] = [:]
        var ftsTerms: [String] = []
        
        // Extract category filters
        if let category = extractCategory(from: query) {
            filters["category"] = category
        }
        
        // Extract color filters
        if let color = extractColor(from: query) {
            filters["color"] = color
        }
        
        // Extract pattern filters
        if let pattern = extractPattern(from: query) {
            filters["pattern"] = pattern
        }
        
        // Extract material filters
        if let material = extractMaterial(from: query) {
            filters["material"] = material
        }
        
        // Extract any remaining search terms for full-text search
        ftsTerms = extractFullTextSearchTerms(from: query, filters: filters)
        
        let fts = ftsTerms.joined(separator: " ")
        
        return (fts: fts, filters: filters)
    }
    
    // MARK: - Extraction Methods
    
    /// Extracts category from the query
    private func extractCategory(from query: String) -> String? {
        let categoryKeywords: [String: String] = [
            "bag": "bag",
            "bags": "bag",
            "purse": "bag",
            "recipe": "recipe",
            "recipes": "recipe",
            "receipt": "receipt",
            "receipts": "receipt",
            "fashion": "fashion",
            "clothing": "fashion",
            "clothes": "fashion",
            "decor": "decor",
            "decoration": "decor",
            "document": "document",
            "documents": "document",
            "note": "note",
            "notes": "note",
            "meal plan": "meal_plan",
            "meal_plan": "meal_plan"
        ]
        
        for (keyword, category) in categoryKeywords {
            if query.contains(keyword) {
                return category
            }
        }
        
        return nil
    }
    
    /// Extracts color from the query
    private func extractColor(from query: String) -> String? {
        let colors = [
            "red", "blue", "green", "yellow", "orange", "purple", "pink",
            "black", "white", "gray", "grey", "brown", "beige", "navy",
            "teal", "turquoise", "maroon", "gold", "silver", "bronze"
        ]
        
        for color in colors {
            if query.contains(color) {
                return color
            }
        }
        
        return nil
    }
    
    /// Extracts pattern from the query
    private func extractPattern(from query: String) -> String? {
        let patterns = [
            "floral", "striped", "polka dot", "checkered", "plaid",
            "geometric", "solid", "abstract", "paisley", "camouflage"
        ]
        
        for pattern in patterns {
            if query.contains(pattern) {
                return pattern
            }
        }
        
        return nil
    }
    
    /// Extracts material from the query
    private func extractMaterial(from query: String) -> String? {
        let materials = [
            "leather", "canvas", "denim", "silk", "cotton", "wool",
            "polyester", "nylon", "suede", "velvet", "satin", "linen"
        ]
        
        for material in materials {
            if query.contains(material) {
                return material
            }
        }
        
        return nil
    }
    
    /// Extracts full-text search terms after removing filter keywords
    private func extractFullTextSearchTerms(from query: String, filters: [String: String]) -> [String] {
        var remainingQuery = query
        
        // Remove filter keywords from the query
        var allKeywords = [
            // Categories
            "bag", "bags", "purse", "recipe", "recipes", "receipt", "receipts",
            "fashion", "clothing", "clothes", "decor", "decoration",
            "document", "documents", "note", "notes", "meal plan", "meal_plan",
            
            // Common stop words
            "with", "and", "or", "the", "a", "an", "in", "on", "at"
        ]
        
        // Add extracted filter values to remove
        for (_, value) in filters {
            if !allKeywords.contains(value) {
                allKeywords.append(value)
            }
        }
        
        // Remove keywords from query
        for keyword in allKeywords {
            remainingQuery = remainingQuery.replacingOccurrences(of: keyword, with: " ")
        }
        
        // Clean up and extract meaningful terms
        let terms = remainingQuery
            .components(separatedBy: .whitespacesAndNewlines)
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }
            .filter { $0.count > 2 } // Only keep terms longer than 2 characters
        
        return terms
    }
}

/// Extension to apply query plan to Core Data fetch requests
extension QueryPlanner {
    /// Builds a predicate from the query plan
    /// - Parameters:
    ///   - fts: Full-text search string
    ///   - filters: Structured filters
    /// - Returns: NSPredicate for Core Data queries
    func buildPredicate(fts: String, filters: [String: String]) -> NSPredicate {
        var predicates: [NSPredicate] = []
        
        // Add category filter
        if let category = filters["category"] {
            predicates.append(NSPredicate(format: "category == %@", category))
        }
        
        // Add color filter (search in dominantColorsJSON)
        if let color = filters["color"] {
            predicates.append(NSPredicate(format: "dominantColorsJSON CONTAINS[cd] %@", color))
        }
        
        // Add pattern filter (search in attributesJSON or tagsCSV)
        if let pattern = filters["pattern"] {
            let patternPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "attributesJSON CONTAINS[cd] %@", pattern),
                NSPredicate(format: "tagsCSV CONTAINS[cd] %@", pattern)
            ])
            predicates.append(patternPredicate)
        }
        
        // Add material filter (search in attributesJSON)
        if let material = filters["material"] {
            predicates.append(NSPredicate(format: "attributesJSON CONTAINS[cd] %@", material))
        }
        
        // Add full-text search
        if !fts.isEmpty {
            let ftsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "title CONTAINS[cd] %@", fts),
                NSPredicate(format: "summary CONTAINS[cd] %@", fts),
                NSPredicate(format: "tagsCSV CONTAINS[cd] %@", fts),
                NSPredicate(format: "ocrText CONTAINS[cd] %@", fts)
            ])
            predicates.append(ftsPredicate)
        }
        
        // Combine all predicates with AND
        if predicates.isEmpty {
            return NSPredicate(value: true) // Return all items
        } else if predicates.count == 1 {
            return predicates[0]
        } else {
            return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
    }
}

