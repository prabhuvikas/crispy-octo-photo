//
//  PhotoMetadata.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import UIKit

/// Contains all metadata associated with a photo
struct PhotoMetadata {
    let image: UIImage
    let location: LocationData?
    let timestamp: Date
    let description: String?
    let cameraMake: String?
    let cameraModel: String?

    init(
        image: UIImage,
        location: LocationData? = nil,
        timestamp: Date = Date(),
        description: String? = nil,
        cameraMake: String? = nil,
        cameraModel: String? = nil
    ) {
        self.image = image
        self.location = location
        self.timestamp = timestamp
        self.description = description
        self.cameraMake = cameraMake
        self.cameraModel = cameraModel
    }

    /// Formatted timestamp string
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    /// Camera info string (e.g., "Apple iPhone 13")
    var cameraInfo: String? {
        if let make = cameraMake, let model = cameraModel {
            return "\(make) \(model)"
        } else if let make = cameraMake {
            return make
        } else if let model = cameraModel {
            return model
        }
        return nil
    }
}
