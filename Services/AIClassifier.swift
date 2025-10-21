import UIKit
import CoreML
import Foundation

enum AIClassifierError: Error {
    case modelNotAvailable
    case generationFailed
    case invalidJSON
    case deviceNotSupported
}

/// Service for classifying items using AI/ML models
class AIClassifier {
    
    /// Classifies an item using Apple's on-device Foundation Models
    /// - Parameters:
    ///   - vision: VisionSummary containing detected objects, text, and colors
    ///   - userHint: Optional user-provided hint about the item
    /// - Returns: ItemRecord with classification details
    /// - Throws: AIClassifierError if generation fails
    func classify(from vision: VisionSummary, userHint: String? = nil) async throws -> ItemRecord {
        // Build the prompt for the language model
        let prompt = buildPrompt(vision: vision, userHint: userHint)
        
        // Attempt to use on-device language model
        do {
            let response = try await generateOnDevice(prompt: prompt)
            let itemRecord = try parseItemRecord(from: response)
            return itemRecord
        } catch {
            // If on-device generation fails, throw specific error
            throw AIClassifierError.deviceNotSupported
        }
    }
    
    /// Generates text using Apple's on-device Foundation Models
    /// - Parameter prompt: The prompt to send to the model
    /// - Returns: Generated text response
    /// - Throws: AIClassifierError if model is not available
    private func generateOnDevice(prompt: String) async throws -> String {
        // Check if Apple Intelligence is available on this device
        // Note: This requires iOS 18+ and Apple Silicon (A17 Pro or M1+)
        
        // Attempt to use the Foundation Models API
        // This is a placeholder for the actual Apple Intelligence API
        // which may vary based on final iOS 18 release
        
        if #available(iOS 18.0, *) {
            // Try to use Apple's on-device text generation
            // Using a simulated implementation as the actual API may differ
            
            // Check for device capability
            guard await isAppleIntelligenceAvailable() else {
                throw AIClassifierError.deviceNotSupported
            }
            
            // Simulate on-device generation with a delay
            // In production, this would call the actual Apple Intelligence API
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            
            // Generate mock response based on vision data
            let response = generateMockResponse(prompt: prompt)
            return response
        } else {
            throw AIClassifierError.deviceNotSupported
        }
    }
    
    /// Checks if Apple Intelligence is available on the current device
    /// - Returns: True if available, false otherwise
    private func isAppleIntelligenceAvailable() async -> Bool {
        // Check device capabilities
        // Apple Intelligence requires:
        // - iOS 18.0+
        // - Apple Silicon (A17 Pro or M-series chips)
        
        // For now, we'll return true on iOS 18+ devices
        // In production, you'd check for specific hardware capabilities
        if #available(iOS 18.0, *) {
            return true
        }
        return false
    }
    
    /// Builds a prompt for the language model
    /// - Parameters:
    ///   - vision: VisionSummary with detected objects, text, and colors
    ///   - userHint: Optional user hint
    /// - Returns: Formatted prompt string
    private func buildPrompt(vision: VisionSummary, userHint: String?) -> String {
        var prompt = """
        You are an inventory classification assistant. Analyze the following information and generate a JSON response.
        
        VISION ANALYSIS:
        - Detected Objects: \(vision.objects.map { "\($0.label) (\(String(format: "%.0f", $0.confidence * 100))%)" }.joined(separator: ", "))
        - OCR Text: \(vision.ocrText.isEmpty ? "None" : vision.ocrText)
        - Colors: \(vision.colors.joined(separator: ", "))
        """
        
        if let hint = userHint, !hint.isEmpty {
            prompt += "\n- User Hint: \(hint)"
        }
        
        prompt += """
        
        
        INSTRUCTIONS:
        Return STRICT JSON matching this exact structure:
        {
          "title": "concise item name (2-5 words)",
          "summary": "brief description (1-2 sentences)",
          "category": "one of: general, grocery, nails, bags, recipe, receipt, fashion, electronics",
          "tags": ["3-10 lowercase singular tags", "no duplicates"],
          "attributes": {
            "color": "primary color if applicable",
            "material": "material if identifiable",
            "finish": "finish/texture if applicable"
          }
        }
        
        RULES:
        - title: short, descriptive, capitalize properly
        - summary: 1-2 sentences describing the item
        - category: MUST be one of the 8 categories listed
        - tags: 3-10 items, lowercase, singular form, no duplicates
        - attributes: structured fields for color, material, finish, etc.
        
        Return ONLY the JSON, no other text.
        """
        
        return prompt
    }
    
    /// Generates a mock response based on the prompt (temporary implementation)
    /// - Parameter prompt: The input prompt
    /// - Returns: JSON string response
    private func generateMockResponse(prompt: String) -> String {
        // Extract vision data from prompt to generate realistic response
        // This is a temporary implementation until real API is available
        
        let categories = ItemRecord.validCategories
        let category = categories.randomElement() ?? "general"
        
        let mockResponse = """
        {
          "title": "Analyzed Item",
          "summary": "An item detected from the image with various characteristics visible.",
          "category": "\(category)",
          "tags": ["item", "analyzed", "photo", "inventory"],
          "attributes": {
            "color": "mixed",
            "material": "unknown",
            "confidence": "high"
          }
        }
        """
        
        return mockResponse
    }
    
    /// Parses ItemRecord from JSON response
    /// - Parameter json: JSON string response
    /// - Returns: Parsed ItemRecord
    /// - Throws: AIClassifierError if parsing fails
    private func parseItemRecord(from json: String) throws -> ItemRecord {
        guard let data = json.data(using: .utf8) else {
            throw AIClassifierError.invalidJSON
        }
        
        do {
            let decoder = JSONDecoder()
            let itemRecord = try decoder.decode(ItemRecord.self, from: data)
            
            // Validate the record
            try validateItemRecord(itemRecord)
            
            return itemRecord
        } catch {
            print("JSON parsing error: \(error)")
            throw AIClassifierError.invalidJSON
        }
    }
    
    /// Validates an ItemRecord
    /// - Parameter record: The ItemRecord to validate
    /// - Throws: AIClassifierError if validation fails
    private func validateItemRecord(_ record: ItemRecord) throws {
        // Validate category
        guard ItemRecord.validCategories.contains(record.category) else {
            throw AIClassifierError.invalidJSON
        }
        
        // Validate tags count
        guard record.tags.count >= 3 && record.tags.count <= 10 else {
            throw AIClassifierError.invalidJSON
        }
        
        // Validate no duplicate tags
        let uniqueTags = Set(record.tags)
        guard uniqueTags.count == record.tags.count else {
            throw AIClassifierError.invalidJSON
        }
    }
    
    // MARK: - Legacy Support
    
    /// Legacy method for backward compatibility
    /// - Parameters:
    ///   - image: The UIImage to classify
    ///   - visionResults: Results from Vision analysis
    /// - Returns: Classification string
    func classify(image: UIImage, visionResults: [String: Any]) async -> String {
        // Extract vision summary from legacy format
        let objects = (visionResults["objects"] as? [[String: Any]])?.compactMap { dict -> DetectedObject? in
            guard let label = dict["label"] as? String,
                  let confidence = dict["confidence"] as? Float else {
                return nil
            }
            return DetectedObject(label: label, confidence: confidence)
        } ?? []
        
        let ocrText = visionResults["text"] as? String ?? ""
        let colors = visionResults["colors"] as? [String] ?? []
        
        let visionSummary = VisionSummary(objects: objects, ocrText: ocrText, colors: colors)
        
        // Try new classification method
        do {
            let itemRecord = try await classify(from: visionSummary, userHint: nil)
            return itemRecord.title
        } catch {
            // Fallback to random category
            return ItemRecord.validCategories.randomElement() ?? "general"
        }
    }
}
