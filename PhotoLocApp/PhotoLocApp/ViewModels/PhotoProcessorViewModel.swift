//
//  PhotoProcessorViewModel.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import Foundation
import UIKit
import CoreLocation
import Combine

/// View model for photo processing
@MainActor
class PhotoProcessorViewModel: ObservableObject {
    @Published var originalImage: UIImage?
    @Published var processedImage: UIImage?
    @Published var metadata: PhotoMetadata?
    @Published var isProcessing = false
    @Published var error: AppError?
    @Published var photoDescription: String = ""

    private let settings = AppSettings.shared
    private let locationService = LocationService()

    // MARK: - Process Photo from Camera

    /// Process a newly captured photo with current location
    func processPhoto(
        image: UIImage,
        location: CLLocation?,
        description: String? = nil
    ) async {
        isProcessing = true
        error = nil

        // Create metadata
        let photoMetadata = PhotoMetadata(
            image: image,
            location: location.map { LocationData(from: $0) },
            timestamp: Date(),
            description: description ?? photoDescription
        )

        await processWithMetadata(image: image, metadata: photoMetadata)
    }

    // MARK: - Process Existing Photo

    /// Process an existing photo from library (extract EXIF)
    func processExistingPhoto(_ image: UIImage) async {
        isProcessing = true
        error = nil

        // Extract metadata from EXIF
        var photoMetadata = EXIFReader.extractMetadata(from: image) ?? PhotoMetadata(image: image)

        // Add user description if provided
        if !photoDescription.isEmpty {
            photoMetadata = PhotoMetadata(
                image: photoMetadata.image,
                location: photoMetadata.location,
                timestamp: photoMetadata.timestamp,
                description: photoDescription,
                cameraMake: photoMetadata.cameraMake,
                cameraModel: photoMetadata.cameraModel
            )
        }

        // If no location in EXIF, try to get current location
        if photoMetadata.location == nil {
            do {
                let currentLocation = try await locationService.requestLocation()
                photoMetadata = PhotoMetadata(
                    image: photoMetadata.image,
                    location: LocationData(from: currentLocation),
                    timestamp: photoMetadata.timestamp,
                    description: photoMetadata.description,
                    cameraMake: photoMetadata.cameraMake,
                    cameraModel: photoMetadata.cameraModel
                )
            } catch {
                // Continue without location
                print("Failed to get current location: \(error)")
            }
        }

        await processWithMetadata(image: image, metadata: photoMetadata)
    }

    // MARK: - Private Processing

    private func processWithMetadata(image: UIImage, metadata: PhotoMetadata) async {
        // Store original and metadata
        self.originalImage = image
        self.metadata = metadata

        // Process in background
        let processed = await Task.detached(priority: .userInitiated) {
            PolaroidCompositor.createPolaroidImage(
                from: image,
                metadata: metadata,
                style: self.settings.currentStyle,
                settings: self.settings
            )
        }.value

        if let processed = processed {
            self.processedImage = processed
        } else {
            self.error = .imageProcessingFailed
        }

        isProcessing = false
    }

    // MARK: - Save to Library

    func saveToLibrary() async throws {
        guard let image = processedImage else {
            throw AppError.noImage
        }

        do {
            try await PhotoLibraryService.saveImage(image)
        } catch {
            throw AppError.saveFailed(error)
        }
    }

    // MARK: - Reset

    func reset() {
        originalImage = nil
        processedImage = nil
        metadata = nil
        error = nil
        isProcessing = false
        photoDescription = ""
    }
}
