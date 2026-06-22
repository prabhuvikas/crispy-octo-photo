//
//  PhotoLibraryService.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import UIKit
import Photos

/// Photo library service errors
enum PhotoLibraryError: LocalizedError {
    case unauthorized
    case saveFailed(Error)
    case noImage

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Photo library access not granted"
        case .saveFailed(let error):
            return "Failed to save photo: \(error.localizedDescription)"
        case .noImage:
            return "No image to save"
        }
    }
}

/// Manages photo library operations
class PhotoLibraryService {

    // MARK: - Check Permission

    static func checkPermission() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus(for: .addOnly)
    }

    static func requestPermission() async -> PHAuthorizationStatus {
        return await PHPhotoLibrary.requestAuthorization(for: .addOnly)
    }

    // MARK: - Save Image

    /// Save image to photo library
    static func saveImage(_ image: UIImage) async throws {
        // Check permission
        let status = checkPermission()
        guard status == .authorized || status == .limited else {
            throw PhotoLibraryError.unauthorized
        }

        return try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                PHAssetCreationRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, error in
                if success {
                    continuation.resume()
                } else if let error = error {
                    continuation.resume(throwing: PhotoLibraryError.saveFailed(error))
                } else {
                    continuation.resume(throwing: PhotoLibraryError.saveFailed(
                        NSError(domain: "PhotoLibraryService", code: -1, userInfo: nil)
                    ))
                }
            }
        }
    }

    /// Save image with metadata
    static func saveImageWithMetadata(
        _ image: UIImage,
        location: CLLocation? = nil,
        creationDate: Date? = nil
    ) async throws {
        let status = checkPermission()
        guard status == .authorized || status == .limited else {
            throw PhotoLibraryError.unauthorized
        }

        return try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .photo, data: image.jpegData(compressionQuality: 0.9)!, options: nil)

                if let location = location {
                    request.location = location
                }

                if let creationDate = creationDate {
                    request.creationDate = creationDate
                }
            } completionHandler: { success, error in
                if success {
                    continuation.resume()
                } else if let error = error {
                    continuation.resume(throwing: PhotoLibraryError.saveFailed(error))
                } else {
                    continuation.resume(throwing: PhotoLibraryError.saveFailed(
                        NSError(domain: "PhotoLibraryService", code: -1, userInfo: nil)
                    ))
                }
            }
        }
    }
}
