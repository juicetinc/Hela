import UIKit
import Vision

/// Service for analyzing images using Apple's Vision framework
class VisionAnalyzer {
    static let shared = VisionAnalyzer()
    
    private init() {}
    
    /// Analyzes a UIImage and returns a VisionSummary
    /// - Parameter image: The UIImage to analyze
    /// - Returns: VisionSummary containing analysis results
    /// - Throws: Error if image cannot be converted to CGImage
    func analyze(image: UIImage) async throws -> VisionSummary {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "VisionAnalyzer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not convert to CGImage"])
        }
        return await analyze(image: cgImage)
    }
    
    /// Analyzes an image and returns detected objects, text, and colors
    /// - Parameter image: The CGImage to analyze
    /// - Returns: VisionSummary containing analysis results
    func analyze(image: CGImage) async -> VisionSummary {
        async let objects = detectObjects(in: image)
        async let text = recognizeText(in: image)
        async let colors = extractColors(from: image)
        
        let (detectedObjects, ocrText, dominantColors) = await (objects, text, colors)
        
        return VisionSummary(
            objects: detectedObjects,
            ocrText: ocrText,
            colors: dominantColors
        )
    }
    
    /// Detects objects in an image using Vision framework
    /// - Parameter image: The CGImage to analyze
    /// - Returns: Array of detected objects with labels and confidence scores
    private func detectObjects(in image: CGImage) async -> [DetectedObject] {
        return await withCheckedContinuation { continuation in
            var isResumed = false
            
            let request = VNClassifyImageRequest { request, error in
                guard !isResumed else { return }
                
                guard error == nil else {
                    print("Object detection error: \(error!.localizedDescription)")
                    isResumed = true
                    continuation.resume(returning: [])
                    return
                }
                
                guard let results = request.results as? [VNClassificationObservation] else {
                    isResumed = true
                    continuation.resume(returning: [])
                    return
                }
                
                // Debug: Print all detected objects
                print("🔍 Vision detected \(results.count) classifications:")
                for (index, observation) in results.prefix(10).enumerated() {
                    print("  \(index + 1). \(observation.identifier) (\(String(format: "%.1f", observation.confidence * 100))%)")
                }
                
                // Filter objects with at least 10% confidence and take top 10
                var objects = results
                    .filter { $0.confidence >= 0.10 }
                    .prefix(10)
                    .map { observation in
                        DetectedObject(
                            label: observation.identifier,
                            confidence: observation.confidence
                        )
                    }
                
                // SIMULATOR FALLBACK: If Vision returned no objects (simulator limitation),
                // use mock data for testing purposes
                #if targetEnvironment(simulator)
                if objects.isEmpty {
                    print("⚠️ Vision failed in simulator. Using mock object detection for testing.")
                    objects = [
                        DetectedObject(label: "flower", confidence: 0.95),
                        DetectedObject(label: "plant", confidence: 0.87),
                        DetectedObject(label: "blossom", confidence: 0.76),
                        DetectedObject(label: "garden", confidence: 0.65),
                        DetectedObject(label: "nature", confidence: 0.58)
                    ]
                }
                #endif
                
                isResumed = true
                continuation.resume(returning: Array(objects))
            }
            
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("Failed to perform object detection: \(error)")
                    if !isResumed {
                        isResumed = true
                        continuation.resume(returning: [])
                    }
                }
            }
        }
    }
    
    /// Recognizes text in an image
    /// - Parameter image: The CGImage to analyze
    /// - Returns: Recognized text string
    private func recognizeText(in image: CGImage) async -> String {
        return await withCheckedContinuation { continuation in
            var isResumed = false
            
            let request = VNRecognizeTextRequest { request, error in
                guard !isResumed else { return }
                
                guard error == nil else {
                    print("Text recognition error: \(error!.localizedDescription)")
                    isResumed = true
                    continuation.resume(returning: "")
                    return
                }
                
                guard let results = request.results as? [VNRecognizedTextObservation] else {
                    isResumed = true
                    continuation.resume(returning: "")
                    return
                }
                
                let recognizedStrings = results.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                
                let fullText = recognizedStrings.joined(separator: " ")
                isResumed = true
                continuation.resume(returning: fullText)
            }
            
            // Configure for fast, accurate recognition
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("Failed to perform text recognition: \(error)")
                    if !isResumed {
                        isResumed = true
                        continuation.resume(returning: "")
                    }
                }
            }
        }
    }
    
    /// Extracts dominant colors from an image
    /// - Parameter image: The CGImage to analyze
    /// - Returns: Array of 3-5 color names
    private func extractColors(from image: CGImage) async -> [String] {
        return await Task.detached {
            DominantColor.extract(from: image)
        }.value
    }
    
}
