import UIKit
import Photos

enum PhotoLibraryError: Error {
    case accessDenied
    case saveFailed
    case noAssetFound
}

/// Service for saving images to the Photos library
class PhotoLibraryService {
    static let shared = PhotoLibraryService()
    
    private init() {}
    
    /// Saves an image to the Photos library and returns the local identifier
    /// - Parameter image: The UIImage to save
    /// - Returns: The PHAsset localIdentifier
    /// - Throws: PhotoLibraryError if saving fails
    func saveImageToLibrary(_ image: UIImage) async throws -> String {
        // Request authorization
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        
        guard status == .authorized else {
            throw PhotoLibraryError.accessDenied
        }
        
        // Save the image and get the local identifier
        return try await withCheckedThrowingContinuation { continuation in
            var localIdentifier: String?
            
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCreationRequest.creationRequestForAsset(from: image)
                localIdentifier = request.placeholderForCreatedAsset?.localIdentifier
            }) { success, error in
                if success, let identifier = localIdentifier {
                    continuation.resume(returning: identifier)
                } else {
                    continuation.resume(throwing: error ?? PhotoLibraryError.saveFailed)
                }
            }
        }
    }
    
    /// Retrieves a PHAsset from a local identifier
    /// - Parameter localIdentifier: The local identifier of the asset
    /// - Returns: The PHAsset if found
    func getAsset(from localIdentifier: String) -> PHAsset? {
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        return fetchResult.firstObject
    }
    
    /// Loads an image from a PHAsset
    /// - Parameter asset: The PHAsset to load
    /// - Returns: The UIImage
    func loadImage(from asset: PHAsset) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = false
            
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}

