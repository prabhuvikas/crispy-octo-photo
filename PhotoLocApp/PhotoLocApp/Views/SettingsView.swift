//
//  SettingsView.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import SwiftUI

/// Settings screen
struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    @StateObject private var permissionManager = PermissionManager()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            // Photo Settings
            Section("Photo Settings") {
                Toggle("Include Timestamp", isOn: $settings.includeTimestamp)

                Toggle("Include Coordinates", isOn: $settings.includeCoordinates)

                Toggle("Auto-save to Library", isOn: $settings.saveToLibraryAutomatically)

                Picker("Polaroid Style", selection: $settings.polaroidStyleName) {
                    Text("Classic").tag("classic")
                    Text("Vintage").tag("vintage")
                    Text("Modern").tag("modern")
                }
            }

            // Default Description
            Section("Default Description") {
                TextField("Enter default description", text: $settings.defaultDescription)
            } footer: {
                Text("This description will be used for new photos unless you specify otherwise.")
                    .font(.caption)
            }

            // Permissions
            Section("Permissions") {
                PermissionStatusRow(
                    title: "Camera",
                    icon: "camera.fill",
                    status: permissionManager.cameraStatus
                )

                PermissionStatusRow(
                    title: "Photo Library",
                    icon: "photo.on.rectangle",
                    status: permissionManager.photoLibraryStatus
                )

                PermissionStatusRow(
                    title: "Location",
                    icon: "location.fill",
                    status: permissionManager.locationStatus
                )

                if hasPermissionIssues {
                    Button("Open Settings") {
                        permissionManager.openSettings()
                    }
                    .foregroundColor(.accentColor)
                }
            }

            // About
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(AppConstants.appVersion)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("App Name")
                    Spacer()
                    Text(AppConstants.appName)
                        .foregroundColor(.secondary)
                }

                Button("Reset to Defaults") {
                    settings.resetToDefaults()
                }
                .foregroundColor(.red)
            }

            // Privacy
            Section("Privacy") {
                VStack(alignment: .leading, spacing: AppConstants.spacing8) {
                    Text("100% Offline")
                        .font(.headline)

                    Text("PhotoLoc works completely offline. All processing happens on your device. No data is ever sent to servers.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, AppConstants.spacing8)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .onAppear {
            permissionManager.checkAllPermissions()
        }
    }

    private var hasPermissionIssues: Bool {
        permissionManager.cameraStatus == .denied ||
        permissionManager.photoLibraryStatus == .denied ||
        permissionManager.locationStatus == .denied
    }
}

// MARK: - Permission Status Row

struct PermissionStatusRow: View {
    let title: String
    let icon: String
    let status: PermissionStatus

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 24)

            Text(title)

            Spacer()

            statusBadge
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch status {
        case .authorized:
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Granted")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        case .denied:
            HStack(spacing: 4) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                Text("Denied")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        case .restricted:
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Restricted")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        case .notDetermined:
            HStack(spacing: 4) {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
                Text("Not Set")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
