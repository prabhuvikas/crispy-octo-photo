//
//  CLLocation+Extensions.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import CoreLocation

extension CLLocation {
    /// Format coordinates as "37.7749° N, 122.4194° W"
    var formattedCoordinates: String {
        let latDirection = coordinate.latitude >= 0 ? "N" : "S"
        let lonDirection = coordinate.longitude >= 0 ? "E" : "W"

        let latValue = abs(coordinate.latitude)
        let lonValue = abs(coordinate.longitude)

        return String(format: "%.4f° %@, %.4f° %@", latValue, latDirection, lonValue, lonDirection)
    }

    /// Short coordinate format "37.7749, -122.4194"
    var shortFormattedCoordinates: String {
        return String(format: "%.4f, %.4f", coordinate.latitude, coordinate.longitude)
    }

    /// Google Maps URL
    var googleMapsURL: String {
        return "https://maps.google.com/?q=\(coordinate.latitude),\(coordinate.longitude)"
    }

    /// Check if location is reasonably accurate
    var isAccurate: Bool {
        return horizontalAccuracy >= 0 && horizontalAccuracy <= AppConstants.locationAccuracyThreshold
    }
}
