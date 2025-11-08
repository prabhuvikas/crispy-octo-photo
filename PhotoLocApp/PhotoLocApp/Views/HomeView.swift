//
//  HomeView.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import SwiftUI

/// Main home screen
struct HomeView: View {
    @StateObject private var permissionManager = PermissionManager()
    @StateObject private var photoProcessor = PhotoProcessorViewModel()
    @StateObject private var locationService = LocationService()

    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var showSettings = false
    @State private var showPermissionPrompt = false
    @State private var capturedImage: UIImage?
    @State private var selectedImage: UIImage?

    var body: some View {
        NavigationView {
            ZStack {
                // Main content
                VStack(spacing: AppConstants.spacing32) {
                    // Hero section
                    VStack(spacing: AppConstants.spacing16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 80))
                            .foregroundColor(.accentColor)

                        Text("PhotoLoc")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Create Polaroid memories\nwith location tags")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, AppConstants.spacing32)

                    Spacer()

                    // Primary actions
                    VStack(spacing: AppConstants.spacing16) {
                        Button(action: handleTakePhoto) {
                            HStack {
                                Image(systemName: "camera.fill")
                                    .font(.title3)
                                Text("Take Photo")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: AppConstants.buttonHeightLarge)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(AppConstants.cornerRadiusMedium)
                        }

                        Button(action: handleSelectPhoto) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title3)
                                Text("Select from Library")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: AppConstants.buttonHeightLarge)
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(AppConstants.cornerRadiusMedium)
                        }
                    }
                    .padding(.horizontal, AppConstants.spacing24)

                    Spacer()
                }

                // Loading overlay
                if photoProcessor.isProcessing {
                    LoadingOverlay(message: "Creating Polaroid...")
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView(capturedImage: $capturedImage)
            }
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPickerView(selectedImage: $selectedImage)
            }
            .sheet(isPresented: $showSettings) {
                NavigationView {
                    SettingsView()
                }
            }
            .sheet(isPresented: $showPermissionPrompt) {
                PermissionPromptView(permissionManager: permissionManager, isPresented: $showPermissionPrompt)
            }
            .navigationDestination(isPresented: $photoProcessor.processedImage.isNotNil) {
                if photoProcessor.processedImage != nil {
                    PolaroidPreviewView(viewModel: photoProcessor)
                }
            }
            .onChange(of: capturedImage) { newValue in
                if let image = newValue {
                    handleCapturedPhoto(image)
                }
            }
            .onChange(of: selectedImage) { newValue in
                if let image = newValue {
                    handleSelectedPhoto(image)
                }
            }
            .errorAlert($photoProcessor.error)
            .onAppear {
                checkPermissions()
            }
        }
    }

    // MARK: - Actions

    private func handleTakePhoto() {
        guard permissionManager.cameraStatus.isAuthorized else {
            showPermissionPrompt = true
            return
        }

        guard permissionManager.locationStatus.isAuthorized else {
            showPermissionPrompt = true
            return
        }

        showCamera = true
    }

    private func handleSelectPhoto() {
        guard permissionManager.photoLibraryStatus.isAuthorized else {
            showPermissionPrompt = true
            return
        }

        showPhotoPicker = true
    }

    private func handleCapturedPhoto(_ image: UIImage) {
        Task {
            // Get current location
            let location = try? await locationService.requestLocation()

            // Process photo
            await photoProcessor.processPhoto(
                image: image,
                location: location
            )

            // Reset for next capture
            capturedImage = nil
        }
    }

    private func handleSelectedPhoto(_ image: UIImage) {
        Task {
            // Process existing photo (will extract EXIF)
            await photoProcessor.processExistingPhoto(image)

            // Reset for next selection
            selectedImage = nil
        }
    }

    private func checkPermissions() {
        permissionManager.checkAllPermissions()

        // Show permissions prompt on first launch
        if permissionManager.cameraStatus == .notDetermined ||
           permissionManager.photoLibraryStatus == .notDetermined ||
           permissionManager.locationStatus == .notDetermined {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showPermissionPrompt = true
            }
        }
    }
}

// MARK: - Helper Extension

extension Optional {
    var isNotNil: Bool {
        return self != nil
    }
}

extension Binding where Value == Optional<UIImage> {
    var isNotNil: Binding<Bool> {
        Binding<Bool>(
            get: { self.wrappedValue != nil },
            set: { if !$0 { self.wrappedValue = nil } }
        )
    }
}
