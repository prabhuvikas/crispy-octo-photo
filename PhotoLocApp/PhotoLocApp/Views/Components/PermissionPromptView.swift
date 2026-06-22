//
//  PermissionPromptView.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import SwiftUI

struct PermissionPromptView: View {
    @ObservedObject var permissionManager: PermissionManager
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: AppConstants.spacing32) {
                // Header
                VStack(spacing: AppConstants.spacing16) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)

                    Text("Permissions Required")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("PhotoLoc needs these permissions to create location-tagged photos")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, AppConstants.spacing32)

                // Permission rows
                VStack(spacing: AppConstants.spacing16) {
                    PermissionRow(
                        icon: "camera.fill",
                        title: "Camera",
                        description: "Capture photos with location",
                        status: permissionManager.cameraStatus
                    )

                    PermissionRow(
                        icon: "photo.on.rectangle",
                        title: "Photo Library",
                        description: "Save and access photos",
                        status: permissionManager.photoLibraryStatus
                    )

                    PermissionRow(
                        icon: "location.fill",
                        title: "Location",
                        description: "Tag photos with GPS coordinates",
                        status: permissionManager.locationStatus
                    )
                }
                .padding(.horizontal)

                Spacer()

                // Action buttons
                VStack(spacing: AppConstants.spacing12) {
                    if needsPermissions {
                        Button(action: requestPermissions) {
                            Text("Grant Permissions")
                                .frame(maxWidth: .infinity)
                                .frame(height: AppConstants.buttonHeightStandard)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(AppConstants.cornerRadiusMedium)
                                .font(.headline)
                        }
                    } else {
                        Button(action: { isPresented = false }) {
                            Text("Continue")
                                .frame(maxWidth: .infinity)
                                .frame(height: AppConstants.buttonHeightStandard)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(AppConstants.cornerRadiusMedium)
                                .font(.headline)
                        }
                    }

                    if hasDeniedPermissions {
                        Button(action: openSettings) {
                            Text("Open Settings")
                                .frame(maxWidth: .infinity)
                                .frame(height: AppConstants.buttonHeightStandard)
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .cornerRadius(AppConstants.cornerRadiusMedium)
                                .font(.headline)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, AppConstants.spacing32)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var needsPermissions: Bool {
        permissionManager.cameraStatus == .notDetermined ||
        permissionManager.photoLibraryStatus == .notDetermined ||
        permissionManager.locationStatus == .notDetermined
    }

    private var hasDeniedPermissions: Bool {
        permissionManager.cameraStatus == .denied ||
        permissionManager.photoLibraryStatus == .denied ||
        permissionManager.locationStatus == .denied
    }

    private func requestPermissions() {
        Task {
            if permissionManager.cameraStatus == .notDetermined {
                _ = await permissionManager.requestCameraPermission()
            }
            if permissionManager.photoLibraryStatus == .notDetermined {
                _ = await permissionManager.requestPhotoLibraryPermission()
            }
            if permissionManager.locationStatus == .notDetermined {
                _ = await permissionManager.requestLocationPermission()
            }
        }
    }

    private func openSettings() {
        permissionManager.openSettings()
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let status: PermissionStatus

    var body: some View {
        HStack(spacing: AppConstants.spacing16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.accentColor)
                .frame(width: 40)

            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Status
            statusIcon
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(AppConstants.cornerRadiusMedium)
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch status {
        case .authorized:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        case .denied:
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
        case .restricted:
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
        case .notDetermined:
            Image(systemName: "circle")
                .foregroundColor(.gray)
        }
    }
}
