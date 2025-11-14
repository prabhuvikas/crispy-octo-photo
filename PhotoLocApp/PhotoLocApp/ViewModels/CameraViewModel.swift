//
//  CameraViewModel.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import Foundation
import UIKit
import CoreLocation
import Combine

/// View model for camera operations
@MainActor
class CameraViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var currentLocation: CLLocation?
    @Published var isLoading = false
    @Published var error: AppError?

    private let locationService: LocationService

    init(locationService: LocationService = LocationService()) {
        self.locationService = locationService
    }

    /// Capture photo with current location
    func capturePhotoWithLocation() async {
        isLoading = true
        error = nil

        do {
            // Try to get current location
            currentLocation = try await locationService.requestLocation()
        } catch {
            // Location failed, but continue without it
            print("Failed to get location: \(error)")
            currentLocation = locationService.getLastKnownLocation()
        }

        isLoading = false
    }

    /// Handle captured photo from camera
    func handleCapturedPhoto(_ image: UIImage, location: CLLocation? = nil) {
        capturedImage = image
        if let location = location {
            currentLocation = location
        }
    }

    /// Reset camera state
    func reset() {
        capturedImage = nil
        currentLocation = nil
        error = nil
        isLoading = false
    }
}
