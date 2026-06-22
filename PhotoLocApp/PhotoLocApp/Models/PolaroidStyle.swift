//
//  PolaroidStyle.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import UIKit

/// Defines the visual style for Polaroid-style photos
struct PolaroidStyle {
    let borderColor: UIColor
    let borderWidth: CGFloat
    let bottomSpaceHeight: CGFloat
    let qrCodeSize: CGSize
    let textFont: UIFont
    let textColor: UIColor
    let textSecondaryColor: UIColor
    let backgroundColor: UIColor

    /// Classic Polaroid style with white border
    static let classic = PolaroidStyle(
        borderColor: .white,
        borderWidth: 20,
        bottomSpaceHeight: 200,
        qrCodeSize: CGSize(width: 120, height: 120),
        textFont: UIFont.systemFont(ofSize: 14, weight: .regular),
        textColor: .label,
        textSecondaryColor: .secondaryLabel,
        backgroundColor: .white
    )

    /// Vintage Polaroid style with cream border
    static let vintage = PolaroidStyle(
        borderColor: UIColor(red: 0.96, green: 0.95, blue: 0.89, alpha: 1.0),
        borderWidth: 20,
        bottomSpaceHeight: 200,
        qrCodeSize: CGSize(width: 120, height: 120),
        textFont: UIFont.systemFont(ofSize: 14, weight: .regular),
        textColor: .darkGray,
        textSecondaryColor: .gray,
        backgroundColor: UIColor(red: 0.96, green: 0.95, blue: 0.89, alpha: 1.0)
    )

    /// Modern minimal style
    static let modern = PolaroidStyle(
        borderColor: .systemBackground,
        borderWidth: 16,
        bottomSpaceHeight: 180,
        qrCodeSize: CGSize(width: 100, height: 100),
        textFont: UIFont.systemFont(ofSize: 13, weight: .medium),
        textColor: .label,
        textSecondaryColor: .secondaryLabel,
        backgroundColor: .systemBackground
    )
}
