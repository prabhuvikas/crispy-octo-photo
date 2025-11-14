//
//  LocationData.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import Foundation
import CoreLocation

/// Represents location data extracted from GPS or photo EXIF
struct LocationData {
    let latitude: Double
    let longitude: Double
    let altitude: Double?
    let timestamp: Date

    /// Creates LocationData from CLLocation
    init(from location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
        self.timestamp = location.timestamp
    }

    /// Creates LocationData from coordinates
    init(latitude: Double, longitude: Double, altitude: Double? = nil, timestamp: Date = Date()) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.timestamp = timestamp
    }

    /// Google Maps URL with coordinates
    var googleMapsURL: String {
        return "https://maps.google.com/?q=\(latitude),\(longitude)"
    }

    /// Formatted coordinates string (e.g., "37.7749° N, 122.4194° W")
    var formattedCoordinates: String {
        let latDirection = latitude >= 0 ? "N" : "S"
        let lonDirection = longitude >= 0 ? "E" : "W"

        let latValue = abs(latitude)
        let lonValue = abs(longitude)

        return String(format: "%.4f° %@, %.4f° %@", latValue, latDirection, lonValue, lonDirection)
    }

    /// Short formatted coordinates (e.g., "37.7749, -122.4194")
    var shortFormattedCoordinates: String {
        return String(format: "%.4f, %.4f", latitude, longitude)
    }
}

// MARK: - Equatable
extension LocationData: Equatable {
    static func == (lhs: LocationData, rhs: LocationData) -> Bool {
        return lhs.latitude == rhs.latitude &&
               lhs.longitude == rhs.longitude &&
               lhs.altitude == rhs.altitude
    }
}
