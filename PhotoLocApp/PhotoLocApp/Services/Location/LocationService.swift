//
//  LocationService.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import Foundation
import CoreLocation
import Combine

/// Location service errors
enum LocationError: LocalizedError {
    case unauthorized
    case unavailable
    case timeout
    case accuracyTooLow

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Location permission not granted"
        case .unavailable:
            return "Location services unavailable"
        case .timeout:
            return "Location request timed out"
        case .accuracyTooLow:
            return "Location accuracy too low"
        }
    }
}

/// Manages location services and GPS data
@MainActor
class LocationService: NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isUpdating = false

    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    private var timeoutTask: Task<Void, Never>?

    override init() {
        super.init()
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
    }

    // MARK: - Request Location

    /// Request a single location update with timeout
    func requestLocation() async throws -> CLLocation {
        // Check authorization
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            throw LocationError.unauthorized
        }

        isUpdating = true
        defer { isUpdating = false }

        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation

            // Start location updates
            locationManager.startUpdatingLocation()

            // Set timeout
            timeoutTask = Task {
                try? await Task.sleep(nanoseconds: UInt64(AppConstants.locationTimeoutSeconds * 1_000_000_000))

                if !Task.isCancelled {
                    await self.handleTimeout()
                }
            }
        }
    }

    /// Get last known location (may be stale)
    func getLastKnownLocation() -> CLLocation? {
        return currentLocation ?? locationManager.location
    }

    // MARK: - Start/Stop Updates

    func startUpdatingLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        locationManager.startUpdatingLocation()
        isUpdating = true
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        isUpdating = false
    }

    // MARK: - Private Helpers

    private func handleTimeout() {
        locationManager.stopUpdatingLocation()
        timeoutTask?.cancel()

        if let continuation = locationContinuation {
            locationContinuation = nil

            // If we have a location, use it even if timeout
            if let location = currentLocation ?? locationManager.location {
                continuation.resume(returning: location)
            } else {
                continuation.resume(throwing: LocationError.timeout)
            }
        }
    }

    private func completeLocationRequest(with location: CLLocation) {
        locationManager.stopUpdatingLocation()
        timeoutTask?.cancel()

        if let continuation = locationContinuation {
            locationContinuation = nil
            continuation.resume(returning: location)
        }
    }

    private func failLocationRequest(with error: Error) {
        locationManager.stopUpdatingLocation()
        timeoutTask?.cancel()

        if let continuation = locationContinuation {
            locationContinuation = nil
            continuation.resume(throwing: error)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        Task { @MainActor in
            currentLocation = location

            // Complete request if waiting and location is accurate enough
            if locationContinuation != nil {
                if location.isAccurate {
                    completeLocationRequest(with: location)
                }
                // Otherwise keep waiting for better accuracy or timeout
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    failLocationRequest(with: LocationError.unauthorized)
                case .locationUnknown:
                    // Try again, don't fail immediately
                    break
                default:
                    failLocationRequest(with: LocationError.unavailable)
                }
            } else {
                failLocationRequest(with: error)
            }
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
        }
    }
}
