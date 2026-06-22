//
//  Constants.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import UIKit

/// App-wide constants
enum AppConstants {
    // MARK: - UI Layout
    static let polaroidBottomHeight: CGFloat = 200
    static let polaroidBorderWidth: CGFloat = 20
    static let qrCodeSize: CGFloat = 120
    static let qrCodePadding: CGFloat = 20
    static let textPadding: CGFloat = 16

    // MARK: - Image Processing
    static let maxImageDimension: CGFloat = 3000
    static let jpegCompressionQuality: CGFloat = 0.9
    static let qrCodeScale: CGFloat = 10.0

    // MARK: - Colors
    static let polaroidBackground = UIColor.white
    static let textPrimary = UIColor.label
    static let textSecondary = UIColor.secondaryLabel

    // MARK: - Spacing (Design System)
    static let spacing4: CGFloat = 4
    static let spacing8: CGFloat = 8
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing24: CGFloat = 24
    static let spacing32: CGFloat = 32

    // MARK: - Corner Radius
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16

    // MARK: - Button Size
    static let buttonHeightStandard: CGFloat = 50
    static let buttonHeightLarge: CGFloat = 56
    static let minimumTapTarget: CGFloat = 44

    // MARK: - Animation
    static let animationDurationShort: TimeInterval = 0.2
    static let animationDurationMedium: TimeInterval = 0.3
    static let animationDurationLong: TimeInterval = 0.5

    // MARK: - Location
    static let locationTimeoutSeconds: TimeInterval = 10.0
    static let locationAccuracyThreshold: Double = 100.0 // meters

    // MARK: - App Info
    static let appName = "PhotoLoc"
    static let appVersion = "1.0.0"
    static let supportEmail = "support@photoloc.app"
}
