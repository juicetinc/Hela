import Foundation

struct VisionSummary: Codable {
    var objects: [DetectedObject]
    var ocrText: String
    var colors: [String]
}

struct DetectedObject: Codable {
    var label: String
    var confidence: Float
}

