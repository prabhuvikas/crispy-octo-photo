//
//  PermissionManager.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import Foundation
import AVFoundation
import Photos
import CoreLocation
import Combine

/// Permission status for app features
enum PermissionStatus: Equatable {
    case notDetermined
    case authorized
    case denied
    case restricted

    var isAuthorized: Bool {
        return self == .authorized
    }
}

/// Manages all app permissions
@MainActor
class PermissionManager: NSObject, ObservableObject {
    @Published var cameraStatus: PermissionStatus = .notDetermined
    @Published var photoLibraryStatus: PermissionStatus = .notDetermined
    @Published var locationStatus: PermissionStatus = .notDetermined

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        checkAllPermissions()
    }

    // MARK: - Check Permissions

    func checkAllPermissions() {
        checkCameraPermission()
        checkPhotoLibraryPermission()
        checkLocationPermission()
    }

    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        cameraStatus = status.toPermissionStatus()
    }

    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        photoLibraryStatus = status.toPermissionStatus()
    }

    private func checkLocationPermission() {
        let status = locationManager.authorizationStatus
        locationStatus = status.toPermissionStatus()
    }

    // MARK: - Request Permissions

    func requestCameraPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor in
                    self.checkCameraPermission()
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    func requestPhotoLibraryPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                Task { @MainActor in
                    self.checkPhotoLibraryPermission()
                    continuation.resume(returning: status == .authorized)
                }
            }
        }
    }

    func requestLocationPermission() async -> Bool {
        // Check current status
        let currentStatus = locationManager.authorizationStatus

        if currentStatus == .authorizedWhenInUse || currentStatus == .authorizedAlways {
            return true
        }

        if currentStatus == .denied || currentStatus == .restricted {
            return false
        }

        // Request permission
        locationManager.requestWhenInUseAuthorization()

        // Wait for delegate callback
        return await withCheckedContinuation { continuation in
            self.locationContinuation = continuation
        }
    }

    private var locationContinuation: CheckedContinuation<Bool, Never>?

    // MARK: - Open Settings

    func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension PermissionManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            checkLocationPermission()

            // Resume continuation if waiting
            if let continuation = locationContinuation {
                locationContinuation = nil
                continuation.resume(returning: locationStatus.isAuthorized)
            }
        }
    }
}

// MARK: - Helper Extensions

private extension AVAuthorizationStatus {
    func toPermissionStatus() -> PermissionStatus {
        switch self {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        @unknown default:
            return .notDetermined
        }
    }
}

private extension PHAuthorizationStatus {
    func toPermissionStatus() -> PermissionStatus {
        switch self {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorized, .limited:
            return .authorized
        @unknown default:
            return .notDetermined
        }
    }
}

private extension CLAuthorizationStatus {
    func toPermissionStatus() -> PermissionStatus {
        switch self {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorizedAlways, .authorizedWhenInUse:
            return .authorized
        @unknown default:
            return .notDetermined
        }
    }
}
