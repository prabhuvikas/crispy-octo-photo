//
//  EXIFReader.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import UIKit
import ImageIO
import CoreLocation

/// Reads EXIF metadata from photos
class EXIFReader {

    /// Extract all metadata from image
    static func extractMetadata(from image: UIImage) -> PhotoMetadata? {
        guard let data = image.jpegData(compressionQuality: 1.0) ?? image.pngData(),
              let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            return nil
        }

        let location = extractLocation(from: properties)
        let timestamp = extractTimestamp(from: properties)
        let (make, model) = extractCameraInfo(from: properties)

        return PhotoMetadata(
            image: image,
            location: location,
            timestamp: timestamp,
            cameraMake: make,
            cameraModel: model
        )
    }

    /// Extract GPS location from EXIF data
    static func extractLocation(from image: UIImage) -> LocationData? {
        guard let data = image.jpegData(compressionQuality: 1.0) ?? image.pngData(),
              let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            return nil
        }

        return extractLocation(from: properties)
    }

    private static func extractLocation(from properties: [String: Any]) -> LocationData? {
        guard let gpsDict = properties[kCGImagePropertyGPSDictionary as String] as? [String: Any] else {
            return nil
        }

        // Extract latitude
        guard let latitude = gpsDict[kCGImagePropertyGPSLatitude as String] as? Double,
              let latitudeRef = gpsDict[kCGImagePropertyGPSLatitudeRef as String] as? String else {
            return nil
        }

        // Extract longitude
        guard let longitude = gpsDict[kCGImagePropertyGPSLongitude as String] as? Double,
              let longitudeRef = gpsDict[kCGImagePropertyGPSLongitudeRef as String] as? String else {
            return nil
        }

        // Apply direction (N/S for latitude, E/W for longitude)
        let lat = latitudeRef == "N" ? latitude : -latitude
        let lon = longitudeRef == "E" ? longitude : -longitude

        // Extract altitude (optional)
        let altitude = gpsDict[kCGImagePropertyGPSAltitude as String] as? Double

        // Extract timestamp (optional)
        let timestamp = extractGPSTimestamp(from: gpsDict) ?? Date()

        return LocationData(
            latitude: lat,
            longitude: lon,
            altitude: altitude,
            timestamp: timestamp
        )
    }

    /// Extract timestamp from EXIF data
    static func extractTimestamp(from image: UIImage) -> Date? {
        guard let data = image.jpegData(compressionQuality: 1.0) ?? image.pngData(),
              let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            return nil
        }

        return extractTimestamp(from: properties)
    }

    private static func extractTimestamp(from properties: [String: Any]) -> Date {
        // Try EXIF DateTime
        if let exifDict = properties[kCGImagePropertyExifDictionary as String] as? [String: Any],
           let dateTimeOriginal = exifDict[kCGImagePropertyExifDateTimeOriginal as String] as? String {
            return parseEXIFDate(dateTimeOriginal) ?? Date()
        }

        // Try TIFF DateTime
        if let tiffDict = properties[kCGImagePropertyTIFFDictionary as String] as? [String: Any],
           let dateTime = tiffDict[kCGImagePropertyTIFFDateTime as String] as? String {
            return parseEXIFDate(dateTime) ?? Date()
        }

        return Date()
    }

    /// Extract camera make and model
    static func extractCameraInfo(from image: UIImage) -> (make: String?, model: String?) {
        guard let data = image.jpegData(compressionQuality: 1.0) ?? image.pngData(),
              let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            return (nil, nil)
        }

        return extractCameraInfo(from: properties)
    }

    private static func extractCameraInfo(from properties: [String: Any]) -> (make: String?, model: String?) {
        guard let tiffDict = properties[kCGImagePropertyTIFFDictionary as String] as? [String: Any] else {
            return (nil, nil)
        }

        let make = tiffDict[kCGImagePropertyTIFFMake as String] as? String
        let model = tiffDict[kCGImagePropertyTIFFModel as String] as? String

        return (make, model)
    }

    // MARK: - Private Helpers

    private static func extractGPSTimestamp(from gpsDict: [String: Any]) -> Date? {
        guard let dateStamp = gpsDict[kCGImagePropertyGPSDateStamp as String] as? String,
              let timeStamp = gpsDict[kCGImagePropertyGPSTimeStamp as String] as? String else {
            return nil
        }

        let dateTimeString = "\(dateStamp) \(timeStamp)"
        return parseGPSDate(dateTimeString)
    }

    private static func parseEXIFDate(_ dateString: String) -> Date? {
        // EXIF format: "2023:12:15 14:30:45"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        return formatter.date(from: dateString)
    }

    private static func parseGPSDate(_ dateString: String) -> Date? {
        // GPS format: "2023:12:15 14:30:45"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.date(from: dateString)
    }
}
