//
//  QRCodeGenerator.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import UIKit
import CoreImage

/// Generates QR codes from strings
class QRCodeGenerator {

    /// Generate QR code image from string
    static func generateQRCode(from string: String, size: CGSize) -> UIImage? {
        guard let data = string.data(using: .utf8) else {
            return nil
        }

        // Create QR code filter
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }

        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("M", forKey: "inputCorrectionLevel") // Medium error correction

        guard let qrImage = qrFilter.outputImage else {
            return nil
        }

        // Scale QR code to desired size
        let scaleX = size.width / qrImage.extent.width
        let scaleY = size.height / qrImage.extent.height
        let scale = min(scaleX, scaleY)

        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let scaledQRImage = qrImage.transformed(by: transform)

        // Convert to UIImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledQRImage, from: scaledQRImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    /// Generate QR code from location (Google Maps URL)
    static func generateLocationQRCode(latitude: Double, longitude: Double, size: CGSize) -> UIImage? {
        let url = "https://maps.google.com/?q=\(latitude),\(longitude)"
        return generateQRCode(from: url, size: size)
    }

    /// Generate QR code from LocationData
    static func generateLocationQRCode(from location: LocationData, size: CGSize) -> UIImage? {
        return generateQRCode(from: location.googleMapsURL, size: size)
    }
}
