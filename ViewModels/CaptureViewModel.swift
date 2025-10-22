import SwiftUI
import PhotosUI
import CoreData

@Observable
class CaptureViewModel {
    var selectedImage: CGImage?
    var isAnalyzing: Bool = false
    var isSaving: Bool = false
    var showSavedIndicator: Bool = false
    var showConfirmation: Bool = false
    var visionSummary: VisionSummary?
    var itemRecord: ItemRecord?
    var classificationError: String?
    var debugJSON: String = ""
    
    // Editable fields for confirmation sheet
    var editableTitle: String = ""
    var editableSummary: String = ""
    var editableCategory: String = "general"
    var editableTags: String = ""
    var editableCollection: String = ""
    var editableQuantity: Int = 1
    
    private let visionAnalyzer = VisionAnalyzer.shared
    private let aiClassifier = AIClassifier.shared
    private let photoLibrary = PhotoLibraryService.shared
    
    /// Processes the selected photo picker item
    func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        // Load the image data
        guard let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data),
              let cgImage = uiImage.cgImage else {
            return
        }
        
        // Update UI state
        await MainActor.run {
            self.selectedImage = cgImage
            self.isAnalyzing = true
            self.debugJSON = ""
            self.classificationError = nil
            self.showSavedIndicator = false
            self.showConfirmation = false
        }
        
        // Analyze the image
        await analyzeImage(cgImage, uiImage: uiImage)
    }
    
    /// Analyzes the selected image using Vision and AI services
    private func analyzeImage(_ cgImage: CGImage, uiImage: UIImage) async {
        do {
            // Use Vision service to analyze image with CGImage
            let visionSummary = try await visionAnalyzer.analyze(image: UIImage(cgImage: cgImage))
            
            // Generate debug JSON for vision results
            let visionJSON = formatAsJSON(visionSummary)
            
            // Update state
            await MainActor.run {
                self.visionSummary = visionSummary
                self.debugJSON = visionJSON
            }
            
            // Use AI classifier to classify the item
            let itemRecord = try await aiClassifier.classify(from: visionSummary, userHint: nil as String?)
            
            // Generate combined debug JSON
            let combinedJSON = formatCombinedJSON(vision: visionSummary, item: itemRecord)
            
            // Update results
            await MainActor.run {
                self.itemRecord = itemRecord
                self.debugJSON = combinedJSON
                self.classificationError = nil
                
                // Populate editable fields
                self.editableTitle = itemRecord.title
                self.editableSummary = itemRecord.summary
                self.editableCategory = itemRecord.category
                self.editableTags = itemRecord.tags.joined(separator: ", ")
                self.editableQuantity = 1
                
                self.isAnalyzing = false
                self.showConfirmation = true
            }
        } catch AIClassifierError.deviceNotSupported {
            await MainActor.run {
                self.classificationError = "Apple Intelligence not available on this device"
                self.isAnalyzing = false
            }
        } catch {
            await MainActor.run {
                self.classificationError = "Classification failed: \(error.localizedDescription)"
                self.isAnalyzing = false
            }
        }
    }
    
    /// Saves the analyzed item to Core Data and Photos library with edited fields
    @MainActor
    func saveItem(viewContext: NSManagedObjectContext) async {
        guard let cgImage = selectedImage,
              let visionSummary = visionSummary else {
            return
        }
        
        // Update UI state
        isSaving = true
        showConfirmation = false
        
        let uiImage = UIImage(cgImage: cgImage)
        
        // Capture values before async work
        let title = editableTitle
        let summary = editableSummary
        let category = editableCategory
        let tagsString = editableTags
        let collection = editableCollection
        let quantity = editableQuantity
        let attributes = itemRecord?.attributes ?? [:]
        
        // Create updated ItemRecord
        let tags = tagsString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let updatedRecord = ItemRecord(
            title: title,
            summary: summary,
            category: category,
            tags: tags,
            attributes: attributes
        )
        
        // Save to Photos library (async, non-blocking)
        // TEMPORARILY DISABLED - Enable when Info.plist is properly configured
        var imageLocalId: String? = nil
        /*
        do {
            imageLocalId = try await photoLibrary.saveImageToLibrary(uiImage)
            print("✅ Image saved to Photos with ID: \(imageLocalId ?? "none")")
        } catch {
            print("⚠️ Failed to save to Photos library: \(error)")
            // Continue anyway - we can still save to Core Data
        }
        */
        print("📸 Skipping Photos library save (disabled for testing)")
        
        // Save to Core Data (all on main queue since viewContext is main-queue concurrent)
        InventoryStore.shared.saveItem(
            image: uiImage,
            itemRecord: updatedRecord,
            visionSummary: visionSummary,
            imageLocalId: imageLocalId,
            collection: collection.isEmpty ? nil : collection,
            quantity: Int16(quantity),
            context: viewContext
        )
        
        // Update UI state
        isSaving = false
        showSavedIndicator = true
        
        // Reset state for next photo
        selectedImage = nil
        itemRecord = nil
        self.visionSummary = nil
        debugJSON = ""
        classificationError = nil
        
        // Hide the "Saved" indicator after 2 seconds
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                self.showSavedIndicator = false
            }
        }
    }
    
    /// Formats VisionSummary as pretty-printed JSON string
    private func formatAsJSON(_ summary: VisionSummary) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        guard let jsonData = try? encoder.encode(summary),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return "{}"
        }
        
        return jsonString
    }
    
    /// Formats combined vision and item record as JSON
    private func formatCombinedJSON(vision: VisionSummary, item: ItemRecord) -> String {
        let combined: [String: Any] = [
            "vision": [
                "objects": vision.objects.map { ["label": $0.label, "confidence": $0.confidence] },
                "ocrText": vision.ocrText,
                "colors": vision.colors
            ],
            "classification": [
                "title": item.title,
                "summary": item.summary,
                "category": item.category,
                "tags": item.tags,
                "attributes": item.attributes.mapValues { $0.value }
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: combined, options: [.prettyPrinted, .sortedKeys]),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return "{}"
        }
        
        return jsonString
    }
    
    /// Resets the view model state
    func reset() {
        selectedImage = nil
        isAnalyzing = false
        isSaving = false
        showSavedIndicator = false
        showConfirmation = false
        visionSummary = nil
        itemRecord = nil
        classificationError = nil
        debugJSON = ""
        editableTitle = ""
        editableSummary = ""
        editableCategory = "general"
        editableTags = ""
        editableCollection = ""
        editableQuantity = 1
    }
}
