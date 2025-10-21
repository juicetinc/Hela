import Foundation
import CoreML

/// Service for importing and processing text notes
class NoteImporter {
    static let shared = NoteImporter()
    
    private init() {}
    
    /// Imports a text note and extracts structured information
    /// - Parameter text: The raw text to import
    /// - Returns: Structured note data with classification
    func importNote(text: String) async -> NoteData {
        // Parse title and body
        let lines = text.components(separatedBy: .newlines)
        let title = extractTitle(text) ?? "Untitled Note"
        let body = lines.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Classify the note content
        let category = await classifyNote(title: title, body: body)
        
        // Extract keywords and tags
        let keywords = extractKeywords(text)
        var tags = ["imported", "apple_notes"]
        
        // Add category-specific tags
        if category == "recipe" {
            tags.append("recipe")
        } else if category == "meal_plan" {
            tags.append("meal_plan")
        }
        
        return NoteData(
            rawText: text,
            title: title,
            body: body,
            category: category,
            tags: tags,
            keywords: keywords,
            detectedFormat: detectFormat(text)
        )
    }
    
    /// Classifies a note based on its content
    /// - Parameters:
    ///   - title: The note title
    ///   - body: The note body
    /// - Returns: Category classification (recipe, meal_plan, or note)
    private func classifyNote(title: String, body: String) async -> String {
        let combinedText = "\(title) \(body)".lowercased()
        
        // Check for recipe indicators
        let recipeKeywords = ["ingredient", "cup", "tablespoon", "teaspoon", "tsp", "tbsp", 
                             "oven", "bake", "cook", "recipe", "serves", "yield", "preparation"]
        let recipeMatches = recipeKeywords.filter { combinedText.contains($0) }.count
        
        // Check for meal plan indicators
        let mealPlanKeywords = ["monday", "tuesday", "wednesday", "thursday", "friday", 
                               "saturday", "sunday", "breakfast", "lunch", "dinner", 
                               "meal plan", "day"]
        let mealPlanMatches = mealPlanKeywords.filter { combinedText.contains($0) }.count
        
        // Classify based on keyword matches
        if recipeMatches >= 2 {
            return "recipe"
        } else if mealPlanMatches >= 2 {
            return "meal_plan"
        } else {
            return "note"
        }
    }
    
    /// Detects the format/type of the note
    private func detectFormat(_ text: String) -> String {
        // Simple heuristics for format detection
        if text.contains("•") || text.contains("-") {
            return "list"
        } else if text.contains("\n\n") {
            return "structured"
        } else {
            return "plain"
        }
    }
    
    /// Extracts a potential title from the note
    private func extractTitle(_ text: String) -> String? {
        // Take first line if it's short enough
        let lines = text.components(separatedBy: .newlines)
        if let firstLine = lines.first, firstLine.count < 60 {
            return firstLine
        }
        return nil
    }
    
    /// Extracts keywords from the text
    private func extractKeywords(_ text: String) -> [String] {
        // Stub implementation
        // In production, this would use NLP to extract meaningful keywords
        let words = text.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 3 }
        
        return Array(Set(words)).prefix(5).map { String($0) }
    }
}

struct NoteData {
    var rawText: String
    var title: String
    var body: String
    var category: String
    var tags: [String]
    var keywords: [String]
    var detectedFormat: String
}

