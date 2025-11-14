//
//  AppError.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import Foundation

/// App-wide error types
enum AppError: LocalizedError, Identifiable {
    case cameraUnavailable
    case locationUnavailable
    case locationPermissionDenied
    case cameraPermissionDenied
    case photoLibraryPermissionDenied
    case imageProcessingFailed
    case noLocationInPhoto
    case qrCodeGenerationFailed
    case saveFailed(Error)
    case noImage
    case unknown(Error)

    var id: String {
        switch self {
        case .cameraUnavailable:
            return "cameraUnavailable"
        case .locationUnavailable:
            return "locationUnavailable"
        case .locationPermissionDenied:
            return "locationPermissionDenied"
        case .cameraPermissionDenied:
            return "cameraPermissionDenied"
        case .photoLibraryPermissionDenied:
            return "photoLibraryPermissionDenied"
        case .imageProcessingFailed:
            return "imageProcessingFailed"
        case .noLocationInPhoto:
            return "noLocationInPhoto"
        case .qrCodeGenerationFailed:
            return "qrCodeGenerationFailed"
        case .saveFailed:
            return "saveFailed"
        case .noImage:
            return "noImage"
        case .unknown:
            return "unknown"
        }
    }

    var title: String {
        switch self {
        case .cameraUnavailable:
            return "Camera Unavailable"
        case .locationUnavailable:
            return "Location Unavailable"
        case .locationPermissionDenied:
            return "Location Permission Denied"
        case .cameraPermissionDenied:
            return "Camera Permission Denied"
        case .photoLibraryPermissionDenied:
            return "Photo Library Permission Denied"
        case .imageProcessingFailed:
            return "Processing Failed"
        case .noLocationInPhoto:
            return "No Location Data"
        case .qrCodeGenerationFailed:
            return "QR Code Failed"
        case .saveFailed:
            return "Save Failed"
        case .noImage:
            return "No Image"
        case .unknown:
            return "Error"
        }
    }

    var message: String {
        switch self {
        case .cameraUnavailable:
            return "Cannot access camera. Please check your device settings."
        case .locationUnavailable:
            return "Unable to determine your location. Please ensure location services are enabled."
        case .locationPermissionDenied:
            return "Location permission is required to tag photos. Please enable it in Settings."
        case .cameraPermissionDenied:
            return "Camera permission is required to take photos. Please enable it in Settings."
        case .photoLibraryPermissionDenied:
            return "Photo library permission is required to save photos. Please enable it in Settings."
        case .imageProcessingFailed:
            return "Failed to process the image. Please try again."
        case .noLocationInPhoto:
            return "This photo doesn't contain location data. You can use your current location instead."
        case .qrCodeGenerationFailed:
            return "Failed to generate QR code. Please try again."
        case .saveFailed(let error):
            return "Failed to save photo: \(error.localizedDescription)"
        case .noImage:
            return "No image available to save."
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }

    var errorDescription: String? {
        return message
    }

    var recoverySuggestion: String? {
        switch self {
        case .cameraPermissionDenied, .locationPermissionDenied, .photoLibraryPermissionDenied:
            return "Open Settings and grant the required permission."
        case .locationUnavailable:
            return "Try moving to a location with better GPS signal or wait a moment."
        case .noLocationInPhoto:
            return "Use the current location option or try a different photo."
        default:
            return "Please try again. If the problem persists, restart the app."
        }
    }
}
