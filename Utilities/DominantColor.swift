import UIKit
import CoreImage

/// Utility for extracting dominant colors from images
struct DominantColor {
    
    /// Extracts 3-5 dominant color names from an image
    /// - Parameter cgImage: The CGImage to analyze
    /// - Returns: Array of normalized color names
    static func extract(from cgImage: CGImage) -> [String] {
        let uiImage = UIImage(cgImage: cgImage)
        
        // Resize image for faster processing
        guard let resizedImage = resizeImage(uiImage, targetSize: CGSize(width: 100, height: 100)),
              let inputImage = CIImage(image: resizedImage) else {
            return ["Unknown"]
        }
        
        // Extract pixels
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(inputImage, from: inputImage.extent) else {
            return ["Unknown"]
        }
        
        // Sample colors from the image
        let colorCounts = sampleColors(from: cgImage)
        
        // Get top 3-5 colors
        let topColors = colorCounts.sorted { $0.value > $1.value }
            .prefix(5)
            .map { $0.key }
        
        return Array(topColors)
    }
    
    /// Samples colors from the image and groups them by name
    private static func sampleColors(from cgImage: CGImage) -> [String: Int] {
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        
        guard let ctx = context else { return [:] }
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var colorCounts: [String: Int] = [:]
        
        // Sample every 10th pixel to speed up processing
        let step = 10
        for y in stride(from: 0, to: height, by: step) {
            for x in stride(from: 0, to: width, by: step) {
                let pixelIndex = (y * width + x) * bytesPerPixel
                
                guard pixelIndex + 2 < pixelData.count else { continue }
                
                let r = CGFloat(pixelData[pixelIndex]) / 255.0
                let g = CGFloat(pixelData[pixelIndex + 1]) / 255.0
                let b = CGFloat(pixelData[pixelIndex + 2]) / 255.0
                
                let colorName = categorizeColor(r: r, g: g, b: b)
                colorCounts[colorName, default: 0] += 1
            }
        }
        
        return colorCounts
    }
    
    /// Categorizes RGB values into simple color names
    private static func categorizeColor(r: CGFloat, g: CGFloat, b: CGFloat) -> String {
        // Calculate brightness and saturation
        let max = Swift.max(r, g, b)
        let min = Swift.min(r, g, b)
        let brightness = max
        let saturation = max == 0 ? 0 : (max - min) / max
        
        // Low saturation means grayscale
        if saturation < 0.15 {
            if brightness < 0.2 {
                return "Black"
            } else if brightness < 0.4 {
                return "Dark Gray"
            } else if brightness < 0.6 {
                return "Gray"
            } else if brightness < 0.85 {
                return "Light Gray"
            } else {
                return "White"
            }
        }
        
        // Determine hue-based color
        if r > g && r > b {
            if g > b * 1.5 {
                return "Orange"
            } else if b > g * 1.2 {
                return "Pink"
            } else {
                return "Red"
            }
        } else if g > r && g > b {
            if r > b * 1.5 {
                return "Yellow"
            } else if b > r * 1.2 {
                return "Cyan"
            } else {
                return "Green"
            }
        } else if b > r && b > g {
            if r > g * 1.3 {
                return "Purple"
            } else if g > r * 1.2 {
                return "Teal"
            } else {
                return "Blue"
            }
        }
        
        // Edge cases
        if r > 0.7 && g > 0.7 && b < 0.5 {
            return "Yellow"
        } else if r > 0.5 && g < 0.3 && b > 0.5 {
            return "Purple"
        } else if r < 0.3 && g > 0.5 && b > 0.5 {
            return "Cyan"
        }
        
        return "Mixed"
    }
    
    /// Resizes an image to a target size for faster processing
    private static func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let ratio = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

