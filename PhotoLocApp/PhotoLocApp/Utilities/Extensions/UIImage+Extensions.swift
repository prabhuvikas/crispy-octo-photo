//
//  UIImage+Extensions.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import UIKit

extension UIImage {
    /// Resize image to fit within maximum dimension while maintaining aspect ratio
    func resized(maxDimension: CGFloat) -> UIImage {
        let scale: CGFloat
        if size.width > size.height {
            scale = maxDimension / size.width
        } else {
            scale = maxDimension / size.height
        }

        if scale >= 1.0 {
            return self // Already smaller than max
        }

        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        return resized(to: newSize)
    }

    /// Resize image to specific size
    func resized(to targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    /// Fix image orientation based on EXIF data
    func fixedOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }

    /// Compress image to JPEG with quality
    func compressed(quality: CGFloat = AppConstants.jpegCompressionQuality) -> Data? {
        return jpegData(compressionQuality: quality)
    }

    /// Create a solid color image
    static func solidColor(_ color: UIColor, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    /// Add border to image
    func withBorder(width: CGFloat, color: UIColor) -> UIImage {
        let newSize = CGSize(
            width: size.width + width * 2,
            height: size.height + width * 2
        )

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { context in
            // Draw border
            color.setFill()
            context.fill(CGRect(origin: .zero, size: newSize))

            // Draw original image
            draw(in: CGRect(
                x: width,
                y: width,
                width: size.width,
                height: size.height
            ))
        }
    }
}
