//
//  AppSettings.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import Foundation
import Combine

/// App-wide settings stored in UserDefaults
class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var polaroidStyleName: String {
        didSet {
            UserDefaults.standard.set(polaroidStyleName, forKey: "polaroidStyleName")
        }
    }

    @Published var includeTimestamp: Bool {
        didSet {
            UserDefaults.standard.set(includeTimestamp, forKey: "includeTimestamp")
        }
    }

    @Published var includeCoordinates: Bool {
        didSet {
            UserDefaults.standard.set(includeCoordinates, forKey: "includeCoordinates")
        }
    }

    @Published var saveToLibraryAutomatically: Bool {
        didSet {
            UserDefaults.standard.set(saveToLibraryAutomatically, forKey: "saveToLibraryAutomatically")
        }
    }

    @Published var defaultDescription: String {
        didSet {
            UserDefaults.standard.set(defaultDescription, forKey: "defaultDescription")
        }
    }

    private init() {
        // Load from UserDefaults or use defaults
        self.polaroidStyleName = UserDefaults.standard.string(forKey: "polaroidStyleName") ?? "classic"
        self.includeTimestamp = UserDefaults.standard.object(forKey: "includeTimestamp") as? Bool ?? true
        self.includeCoordinates = UserDefaults.standard.object(forKey: "includeCoordinates") as? Bool ?? true
        self.saveToLibraryAutomatically = UserDefaults.standard.object(forKey: "saveToLibraryAutomatically") as? Bool ?? true
        self.defaultDescription = UserDefaults.standard.string(forKey: "defaultDescription") ?? ""
    }

    /// Get the current Polaroid style
    var currentStyle: PolaroidStyle {
        switch polaroidStyleName {
        case "vintage":
            return .vintage
        case "modern":
            return .modern
        default:
            return .classic
        }
    }

    /// Reset all settings to defaults
    func resetToDefaults() {
        polaroidStyleName = "classic"
        includeTimestamp = true
        includeCoordinates = true
        saveToLibraryAutomatically = true
        defaultDescription = ""
    }
}
