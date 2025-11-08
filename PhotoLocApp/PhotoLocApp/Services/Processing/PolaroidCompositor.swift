//
//  PolaroidCompositor.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import UIKit
import CoreGraphics

/// Dimensions for Polaroid layout
struct PolaroidDimensions {
    let totalSize: CGSize
    let photoFrame: CGRect
    let bottomFrame: CGRect
    let qrCodeFrame: CGRect
    let textFrame: CGRect
}

/// Composites photos into Polaroid-style images
class PolaroidCompositor {

    /// Create a Polaroid-style image from photo and metadata
    static func createPolaroidImage(
        from photo: UIImage,
        metadata: PhotoMetadata,
        style: PolaroidStyle,
        settings: AppSettings = .shared
    ) -> UIImage? {
        // Resize photo if too large
        let resizedPhoto = photo.size.width > AppConstants.maxImageDimension || photo.size.height > AppConstants.maxImageDimension
            ? photo.resized(maxDimension: AppConstants.maxImageDimension)
            : photo

        // Calculate dimensions
        let dimensions = calculateDimensions(for: resizedPhoto, style: style)

        // Generate QR code if location available
        var qrCodeImage: UIImage?
        if let location = metadata.location {
            qrCodeImage = QRCodeGenerator.generateLocationQRCode(
                from: location,
                size: style.qrCodeSize
            )
        }

        // Create composite image
        return createComposite(
            photo: resizedPhoto,
            qrCode: qrCodeImage,
            metadata: metadata,
            dimensions: dimensions,
            style: style,
            settings: settings
        )
    }

    // MARK: - Private Methods

    private static func calculateDimensions(for photo: UIImage, style: PolaroidStyle) -> PolaroidDimensions {
        let photoSize = photo.size
        let borderWidth = style.borderWidth
        let bottomHeight = style.bottomSpaceHeight

        // Total size includes photo + borders + bottom space
        let totalWidth = photoSize.width + (borderWidth * 2)
        let totalHeight = photoSize.height + borderWidth + bottomHeight + borderWidth

        let totalSize = CGSize(width: totalWidth, height: totalHeight)

        // Photo frame (within borders)
        let photoFrame = CGRect(
            x: borderWidth,
            y: borderWidth,
            width: photoSize.width,
            height: photoSize.height
        )

        // Bottom white space frame
        let bottomFrame = CGRect(
            x: borderWidth,
            y: photoFrame.maxY,
            width: photoSize.width,
            height: bottomHeight
        )

        // QR code frame (bottom-left)
        let qrPadding: CGFloat = 20
        let qrCodeFrame = CGRect(
            x: bottomFrame.minX + qrPadding,
            y: bottomFrame.minY + (bottomHeight - style.qrCodeSize.height) / 2,
            width: style.qrCodeSize.width,
            height: style.qrCodeSize.height
        )

        // Text frame (to the right of QR code)
        let textPadding: CGFloat = 16
        let textFrame = CGRect(
            x: qrCodeFrame.maxX + textPadding,
            y: bottomFrame.minY + textPadding,
            width: bottomFrame.width - qrCodeFrame.width - qrPadding - textPadding - textPadding,
            height: bottomFrame.height - textPadding * 2
        )

        return PolaroidDimensions(
            totalSize: totalSize,
            photoFrame: photoFrame,
            bottomFrame: bottomFrame,
            qrCodeFrame: qrCodeFrame,
            textFrame: textFrame
        )
    }

    private static func createComposite(
        photo: UIImage,
        qrCode: UIImage?,
        metadata: PhotoMetadata,
        dimensions: PolaroidDimensions,
        style: PolaroidStyle,
        settings: AppSettings
    ) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(dimensions.totalSize, true, 0)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        // 1. Draw background (border color)
        context.setFillColor(style.borderColor.cgColor)
        context.fill(CGRect(origin: .zero, size: dimensions.totalSize))

        // 2. Draw photo
        photo.draw(in: dimensions.photoFrame)

        // 3. Draw bottom white space
        context.setFillColor(style.backgroundColor.cgColor)
        context.fill(dimensions.bottomFrame)

        // 4. Draw QR code if available
        if let qrCode = qrCode {
            qrCode.draw(in: dimensions.qrCodeFrame)
        }

        // 5. Draw text content
        drawText(
            in: dimensions.textFrame,
            metadata: metadata,
            style: style,
            settings: settings
        )

        // Get final image
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    private static func drawText(
        in rect: CGRect,
        metadata: PhotoMetadata,
        style: PolaroidStyle,
        settings: AppSettings
    ) {
        var yOffset: CGFloat = 0
        let lineSpacing: CGFloat = 6

        // Helper to draw text line
        func drawLine(_ text: String, font: UIFont, color: UIColor) {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: color
            ]

            let size = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: rect.minX,
                y: rect.minY + yOffset,
                width: rect.width,
                height: size.height
            )

            text.draw(in: textRect, withAttributes: attributes)
            yOffset += size.height + lineSpacing
        }

        // Location coordinates
        if settings.includeCoordinates, let location = metadata.location {
            drawLine(
                location.formattedCoordinates,
                font: style.textFont,
                color: style.textColor
            )
        }

        // Timestamp
        if settings.includeTimestamp {
            let timestamp = metadata.formattedTimestamp
            drawLine(
                timestamp,
                font: UIFont.systemFont(ofSize: style.textFont.pointSize - 1, weight: .regular),
                color: style.textSecondaryColor
            )
        }

        // Description
        if let description = metadata.description, !description.isEmpty {
            yOffset += 4 // Extra spacing before description
            drawLine(
                description,
                font: UIFont.systemFont(ofSize: style.textFont.pointSize, weight: .medium),
                color: style.textColor
            )
        }

        // Camera info (if available and space permits)
        if let cameraInfo = metadata.cameraInfo, yOffset < rect.height - 20 {
            yOffset += 4
            drawLine(
                cameraInfo,
                font: UIFont.systemFont(ofSize: style.textFont.pointSize - 2, weight: .light),
                color: style.textSecondaryColor
            )
        }
    }
}
