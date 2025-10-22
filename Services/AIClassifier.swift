import UIKit
import CoreML
import Foundation

// Import Apple Intelligence Framework (iOS 18+)
#if canImport(AppleIntelligence)
import AppleIntelligence
#endif

enum AIClassifierError: Error {
    case modelNotAvailable
    case generationFailed
    case invalidJSON
    case deviceNotSupported
    case apiKeyMissing
    case networkError
    case appleIntelligenceNotAvailable
}

/// Service for classifying items using AI/ML models
class AIClassifier {
    static let shared = AIClassifier()
    
    // OpenAI API configuration
    private var openAIKey: String? {
        // Try to load from environment variable or config
        ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
    }
    
    private let openAIEndpoint = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-4o-mini" // Cost-effective and fast
    
    private init() {}
    
    /// Classifies an item using Apple Intelligence, ChatGPT, or mock (in that order)
    /// - Parameters:
    ///   - vision: VisionSummary containing detected objects, text, and colors
    ///   - userHint: Optional user-provided hint about the item
    /// - Returns: ItemRecord with classification details
    /// - Throws: AIClassifierError if all methods fail
    func classify(from vision: VisionSummary, userHint: String? = nil) async throws -> ItemRecord {
        // Build the prompt for the language model
        let prompt = buildPrompt(vision: vision, userHint: userHint)
        
        // Try 1: Apple Intelligence (on-device, fast, private, free!)
        if #available(iOS 18.0, *) {
            do {
                print("🍎 Trying Apple Intelligence...")
                let response = try await generateWithAppleIntelligence(prompt: prompt)
                let itemRecord = try parseItemRecord(from: response)
                print("✅ Apple Intelligence classification successful")
                return itemRecord
            } catch {
                print("⚠️ Apple Intelligence failed: \(error). Trying fallback...")
            }
        }
        
        // Try 2: ChatGPT API (requires internet & API key)
        if let apiKey = openAIKey, !apiKey.isEmpty {
            do {
                print("🤖 Trying ChatGPT API...")
                let response = try await callChatGPT(prompt: prompt, apiKey: apiKey)
                let itemRecord = try parseItemRecord(from: response)
                print("✅ ChatGPT classification successful")
                return itemRecord
            } catch {
                print("⚠️ ChatGPT failed: \(error). Falling back to mock...")
            }
        }
        
        // Try 3: Mock response (always works, uses Vision data)
        print("📝 Using mock classification...")
        let response = generateMockResponse(prompt: prompt)
        let itemRecord = try parseItemRecord(from: response)
        return itemRecord
    }
    
    /// Generates text using Apple Intelligence Foundation Models
    /// - Parameter prompt: The prompt to send to the model
    /// - Returns: Generated JSON response
    /// - Throws: AIClassifierError if Apple Intelligence is not available
    @available(iOS 18.0, *)
    private func generateWithAppleIntelligence(prompt: String) async throws -> String {
        #if canImport(AppleIntelligence)
        // Check if Apple Intelligence is available on this device
        guard AIFoundationModel.isAvailable else {
            throw AIClassifierError.appleIntelligenceNotAvailable
        }
        
        // Get the on-device foundation model
        let model = try AIFoundationModel.shared()
        
        // Configure the generation parameters
        var config = AIGenerationConfig()
        config.maxTokens = 500
        config.temperature = 0.7
        config.systemPrompt = "You are a helpful inventory classification assistant. Always respond with valid JSON only, no other text."
        
        // Generate the response
        let response = try await model.generate(prompt: prompt, config: config)
        
        return response.text
        #else
        // Apple Intelligence framework not available
        throw AIClassifierError.appleIntelligenceNotAvailable
        #endif
    }
    
    
    /// Calls the ChatGPT API with the given prompt
    /// - Parameters:
    ///   - prompt: The prompt to send
    ///   - apiKey: OpenAI API key
    /// - Returns: Generated JSON response
    /// - Throws: AIClassifierError if API call fails
    private func callChatGPT(prompt: String, apiKey: String) async throws -> String {
        guard let url = URL(string: openAIEndpoint) else {
            throw AIClassifierError.networkError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "model": model,
            "messages": [
                [
                    "role": "system",
                    "content": "You are a helpful inventory classification assistant. Always respond with valid JSON only, no other text."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": 0.7,
            "max_tokens": 500
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIClassifierError.networkError
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ OpenAI API error: Status \(httpResponse.statusCode)")
            if let errorBody = String(data: data, encoding: .utf8) {
                print("Error body: \(errorBody)")
            }
            throw AIClassifierError.networkError
        }
        
        // Parse the OpenAI response
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIClassifierError.invalidJSON
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
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
          "tags": ["5-15 searchable tags"],
          "attributes": {
            "color": "primary color if applicable",
            "material": "material if identifiable",
            "context": "usage context if identifiable"
          }
        }
        
        TAGGING RULES (IMPORTANT):
        Generate UNIVERSAL, SEARCHABLE tags that help find this item later.
        Include tags from these categories:
        1. COLORS: Visible colors (e.g., "blue", "red", "multicolor")
        2. MATERIALS: What it's made of (e.g., "fabric", "metal", "plastic", "paper")
        3. FUNCTION: What it does/is for (e.g., "wearable", "consumable", "decorative", "tool")
        4. CONTEXT: Where/how used (e.g., "kitchen", "bathroom", "outdoor", "gift")
        5. ATTRIBUTES: Notable features (e.g., "portable", "vintage", "handmade")
        6. TYPE: Specific object type (e.g., "book", "mug", "plant", "electronics")
        7. BRAND/TEXT: Any readable text, brand names, or labels
        8. CATEGORY: Broad categories (e.g., "food", "beverage", "skincare", "home", "tech")
        
        Examples:
        - Coffee mug → ["ceramic", "mug", "beverage", "kitchen", "blue", "reusable"]
        - Book → ["paper", "book", "reading", "portable", "education", "red"]
        - Plant → ["green", "plant", "decorative", "indoor", "living", "natural"]
        - Toothpaste → ["consumable", "dental", "bathroom", "hygiene", "tube", "white"]
        
        RULES:
        - Tags must be lowercase, singular form
        - No duplicates
        - 5-15 tags for maximum searchability
        - Think: "What would I search for to find this again?"
        - Be flexible and creative based on what you see
        
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
        
        // Parse detected objects from prompt
        var detectedLabels: [String] = []
        if let objectsRange = prompt.range(of: "Detected Objects: "),
           let endRange = prompt[objectsRange.upperBound...].range(of: "\n") {
            let objectsText = prompt[objectsRange.upperBound..<endRange.lowerBound]
            detectedLabels = objectsText.components(separatedBy: ", ").compactMap { item in
                // Extract just the label before the percentage
                let parts = item.components(separatedBy: " (")
                return parts.first?.lowercased()
            }
        }
        
        print("📊 Mock classifier - Detected labels: \(detectedLabels)")
        
        // Parse colors from prompt
        var colors: [String] = []
        if let colorsRange = prompt.range(of: "Colors: "),
           let endRange = prompt[colorsRange.upperBound...].range(of: "\n") {
            let colorsText = prompt[colorsRange.upperBound..<endRange.lowerBound]
            colors = colorsText.components(separatedBy: ", ").map { $0.lowercased() }
        }
        
        print("🎨 Mock classifier - Colors: \(colors)")
        
        // Parse OCR text for additional context
        var ocrKeywords: [String] = []
        if let textRange = prompt.range(of: "OCR Text: "),
           let endRange = prompt[textRange.upperBound...].range(of: "\n") {
            let ocrText = prompt[textRange.upperBound..<endRange.lowerBound]
            if ocrText != "None" && ocrText != "" {
                ocrKeywords = ocrText.components(separatedBy: " ")
                    .filter { $0.count > 3 && $0.count < 20 } // Reasonable length
                    .map { word in
                        // Clean up: lowercase, remove punctuation and special chars
                        word.lowercased()
                            .trimmingCharacters(in: .punctuationCharacters)
                            .trimmingCharacters(in: .whitespaces)
                            .replacingOccurrences(of: "\"", with: "")
                            .replacingOccurrences(of: "\\", with: "")
                            .replacingOccurrences(of: "\n", with: "")
                    }
                    .filter { !$0.isEmpty } // Remove empty strings
                    .prefix(3)
                    .map { String($0) }
            }
        }
        
        print("📖 OCR keywords: \(ocrKeywords)")
        
        // Determine category based on detected objects and text
        let category = determineCategory(from: detectedLabels, ocrText: ocrKeywords)
        
        // Generate title from top detected object
        let title = generateTitle(from: detectedLabels, colors: colors)
        
        // Generate summary
        let summary = generateSummary(from: detectedLabels, colors: colors)
        
        // Generate UNIVERSAL, AI-STYLE tags
        var tags = Set<String>()
        
        // 1. Colors (always useful)
        tags.formUnion(colors.prefix(3))
        print("🎨 Colors: \(colors.prefix(3))")
        
        // 2. Materials (derived from Vision labels)
        let materialTags = deriveUniversalMaterialTags(from: detectedLabels)
        tags.formUnion(materialTags)
        print("🔨 Materials: \(materialTags)")
        
        // 3. Function/Purpose (general categories)
        let functionTags = deriveUniversalFunctionTags(from: detectedLabels)
        tags.formUnion(functionTags)
        print("🎯 Function: \(functionTags)")
        
        // 4. Context (where/how it's used)
        let contextTags = deriveUniversalContextTags(from: detectedLabels)
        tags.formUnion(contextTags)
        print("🌍 Context: \(contextTags)")
        
        // 5. Object type (top 3-4 detected objects)
        let objectTags = detectedLabels.prefix(4)
            .filter { label in
                let lower = label.lowercased()
                return !lower.contains("item") && 
                       !lower.contains("thing") && 
                       !lower.contains("object") &&
                       lower.count > 2
            }
        tags.formUnion(objectTags)
        print("📦 Objects: \(objectTags)")
        
        // 6. OCR text (brands, labels, text - VERY IMPORTANT!)
        tags.formUnion(ocrKeywords)
        print("📝 OCR: \(ocrKeywords)")
        
        // Ensure we have at least 5 tags for searchability
        if tags.count < 5 {
            tags.insert("photo")
            tags.insert("tracked")
            if !colors.isEmpty {
                tags.insert("visual")
            }
        }
        
        print("🏷️ Final tags (\(tags.count)): \(tags)")
        
        let tagsArray = Array(tags.prefix(12)) // Limit to 12 tags for searchability
        // Escape each tag for JSON
        let tagsJSON = tagsArray.map { tag in
            let escaped = tag
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
                .replacingOccurrences(of: "\n", with: "\\n")
            return "\"\(escaped)\""
        }.joined(separator: ", ")
        
        // Get primary color
        let primaryColor = colors.first ?? "mixed"
        
        // Escape strings for JSON (replace quotes, newlines, backslashes)
        let escapedTitle = title
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
        
        let escapedSummary = summary
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
        
        let mockResponse = """
        {
          "title": "\(escapedTitle)",
          "summary": "\(escapedSummary)",
          "category": "\(category)",
          "tags": [\(tagsJSON)],
          "attributes": {
            "color": "\(primaryColor)",
            "material": "unknown",
            "confidence": "high"
          }
        }
        """
        
        print("📝 Generated mock JSON:")
        print(mockResponse)
        
        return mockResponse
    }
    
    // MARK: - Universal Tag Derivation (Works for ANY object)
    
    /// Derives material tags from Vision labels (universal for all objects)
    private func deriveUniversalMaterialTags(from objects: [String]) -> Set<String> {
        var tags = Set<String>()
        let joined = objects.joined(separator: " ").lowercased()
        
        // Common materials that Vision can detect
        if joined.contains("fabric") || joined.contains("textile") || joined.contains("cloth") {
            tags.insert("fabric")
        }
        if joined.contains("metal") || joined.contains("steel") || joined.contains("aluminum") {
            tags.insert("metal")
        }
        if joined.contains("wood") || joined.contains("wooden") {
            tags.insert("wood")
        }
        if joined.contains("plastic") || joined.contains("polymer") {
            tags.insert("plastic")
        }
        if joined.contains("paper") || joined.contains("cardboard") {
            tags.insert("paper")
        }
        if joined.contains("glass") {
            tags.insert("glass")
        }
        if joined.contains("ceramic") || joined.contains("porcelain") {
            tags.insert("ceramic")
        }
        if joined.contains("leather") {
            tags.insert("leather")
        }
        
        return tags
    }
    
    /// Derives functional tags (what the object does/is used for)
    private func deriveUniversalFunctionTags(from objects: [String]) -> Set<String> {
        var tags = Set<String>()
        let joined = objects.joined(separator: " ").lowercased()
        
        // Function categories
        if joined.contains("clothing") || joined.contains("apparel") || joined.contains("footwear") {
            tags.insert("wearable")
        }
        if joined.contains("food") || joined.contains("beverage") || joined.contains("drink") {
            tags.insert("consumable")
        }
        if joined.contains("book") || joined.contains("document") || joined.contains("text") {
            tags.insert("readable")
        }
        if joined.contains("tool") || joined.contains("equipment") || joined.contains("instrument") {
            tags.insert("functional")
        }
        if joined.contains("toy") || joined.contains("game") {
            tags.insert("entertainment")
        }
        if joined.contains("decoration") || joined.contains("plant") || joined.contains("flower") {
            tags.insert("decorative")
        }
        if joined.contains("electronic") || joined.contains("device") || joined.contains("computer") {
            tags.insert("electronic")
        }
        if joined.contains("container") || joined.contains("bottle") || joined.contains("box") {
            tags.insert("storage")
        }
        
        return tags
    }
    
    /// Derives context tags (where/how the object is typically used)
    private func deriveUniversalContextTags(from objects: [String]) -> Set<String> {
        var tags = Set<String>()
        let joined = objects.joined(separator: " ").lowercased()
        
        // Location/usage contexts
        if joined.contains("kitchen") || joined.contains("cooking") || joined.contains("food") {
            tags.insert("kitchen")
        }
        if joined.contains("bathroom") || joined.contains("hygiene") || joined.contains("personal care") {
            tags.insert("bathroom")
        }
        if joined.contains("outdoor") || joined.contains("nature") || joined.contains("garden") {
            tags.insert("outdoor")
        }
        if joined.contains("indoor") || joined.contains("room") || joined.contains("furniture") {
            tags.insert("indoor")
        }
        if joined.contains("office") || joined.contains("desk") || joined.contains("workspace") {
            tags.insert("workspace")
        }
        if joined.contains("portable") || joined.contains("travel") || joined.contains("handheld") {
            tags.insert("portable")
        }
        if joined.contains("gift") || joined.contains("present") {
            tags.insert("gift")
        }
        
        return tags
    }
    
    /// Determines the most appropriate category based on detected objects and text
    private func determineCategory(from objects: [String], ocrText: [String]) -> String {
        let allText = (objects + ocrText).joined(separator: " ").lowercased()
        
        // Category keywords
        if allText.contains("receipt") || allText.contains("price") || allText.contains("total") {
            return "receipt"
        } else if allText.contains("food") || allText.contains("vegetable") || allText.contains("fruit") {
            return "grocery"
        } else if allText.contains("bag") || allText.contains("purse") || allText.contains("tote") {
            return "bags"
        } else if allText.contains("cloth") || allText.contains("shirt") || allText.contains("dress") || allText.contains("fashion") {
            return "fashion"
        } else if allText.contains("phone") || allText.contains("computer") || allText.contains("electronic") {
            return "electronics"
        } else if allText.contains("nail") || allText.contains("polish") {
            return "nails"
        } else if allText.contains("recipe") || allText.contains("ingredient") {
            return "recipe"
        }
        
        return "general"
    }
    
    /// Generates a title from detected objects and colors
    private func generateTitle(from objects: [String], colors: [String]) -> String {
        // Clean up object labels (remove underscores, technical terms)
        let cleanedObjects = objects.map { label in
            label.replacingOccurrences(of: "_", with: " ")
                .components(separatedBy: ",").first ?? label
        }
        
        // Get the most descriptive object (prefer specific over generic)
        var bestObject: String?
        for obj in cleanedObjects {
            let lower = obj.lowercased()
            // Skip generic terms
            if lower.contains("item") || lower.contains("thing") || lower.contains("object") {
                continue
            }
            bestObject = obj
            break
        }
        
        if let objectName = bestObject, !objectName.isEmpty {
            // Capitalize properly
            let words = objectName.split(separator: " ").map { $0.capitalized }
            let capitalizedName = words.joined(separator: " ")
            
            // Add color prefix if available
            if let firstColor = colors.first, !firstColor.isEmpty {
                return "\(firstColor.capitalized) \(capitalizedName)"
            }
            return capitalizedName
        }
        
        // Fallback to color-based naming
        if !colors.isEmpty {
            let colorList = colors.prefix(2).map { $0.capitalized }.joined(separator: " and ")
            return "\(colorList) Flowers" // Assume flowers if we see colors
        }
        
        return "Captured Item"
    }
    
    /// Generates a summary from detected objects and colors
    private func generateSummary(from objects: [String], colors: [String]) -> String {
        // Clean up object labels
        let cleanedObjects = objects
            .map { label in
                label.replacingOccurrences(of: "_", with: " ")
                    .components(separatedBy: ",").first ?? label
            }
            .filter { obj in
                let lower = obj.lowercased()
                // Filter out generic terms
                return !lower.contains("item") && !lower.contains("thing") && !lower.contains("object")
            }
        
        if cleanedObjects.isEmpty && colors.isEmpty {
            return "An item captured from your photo library with various characteristics visible."
        }
        
        if cleanedObjects.isEmpty && !colors.isEmpty {
            let colorList = colors.prefix(3).map { $0.lowercased() }.joined(separator: ", ")
            return "Beautiful image featuring \(colorList) colors prominently displayed."
        }
        
        // Create natural-sounding description
        let objectList = cleanedObjects.prefix(3).map { $0.lowercased() }.joined(separator: ", ")
        let colorList = colors.prefix(2).map { $0.lowercased() }.joined(separator: " and ")
        
        if !colors.isEmpty && !cleanedObjects.isEmpty {
            return "This image features \(objectList) with vibrant \(colorList) colors."
        } else if !cleanedObjects.isEmpty {
            return "This image shows \(objectList) clearly visible in the photo."
        } else {
            return "An interesting item captured from your photo library."
        }
    }
    
    /// Parses ItemRecord from JSON response
    /// - Parameter json: JSON string response
    /// - Returns: Parsed ItemRecord
    /// - Throws: AIClassifierError if parsing fails
    private func parseItemRecord(from json: String) throws -> ItemRecord {
        guard let data = json.data(using: .utf8) else {
            print("❌ Failed to convert JSON string to data")
            throw AIClassifierError.invalidJSON
        }
        
        do {
            let decoder = JSONDecoder()
            let itemRecord = try decoder.decode(ItemRecord.self, from: data)
            
            // Validate the record
            try validateItemRecord(itemRecord)
            
            print("✅ Successfully parsed ItemRecord: \(itemRecord.title)")
            return itemRecord
        } catch let DecodingError.dataCorrupted(context) {
            print("❌ JSON Decoding Error - Data Corrupted:")
            print("   Context: \(context)")
            print("   JSON was: \(json)")
            throw AIClassifierError.invalidJSON
        } catch let DecodingError.keyNotFound(key, context) {
            print("❌ JSON Decoding Error - Key Not Found:")
            print("   Key: \(key)")
            print("   Context: \(context)")
            print("   JSON was: \(json)")
            throw AIClassifierError.invalidJSON
        } catch let DecodingError.typeMismatch(type, context) {
            print("❌ JSON Decoding Error - Type Mismatch:")
            print("   Expected type: \(type)")
            print("   Context: \(context)")
            print("   JSON was: \(json)")
            throw AIClassifierError.invalidJSON
        } catch let DecodingError.valueNotFound(type, context) {
            print("❌ JSON Decoding Error - Value Not Found:")
            print("   Expected type: \(type)")
            print("   Context: \(context)")
            print("   JSON was: \(json)")
            throw AIClassifierError.invalidJSON
        } catch {
            print("❌ JSON parsing error (unknown): \(error)")
            print("   JSON was: \(json)")
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
        
        // Validate tags count (allow 3-15 tags for better searchability)
        guard record.tags.count >= 3 && record.tags.count <= 15 else {
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
