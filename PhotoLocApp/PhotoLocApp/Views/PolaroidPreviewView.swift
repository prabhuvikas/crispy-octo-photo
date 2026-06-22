//
//  PolaroidPreviewView.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import SwiftUI

/// Preview and save Polaroid-style photo
struct PolaroidPreviewView: View {
    @ObservedObject var viewModel: PhotoProcessorViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var isEditingDescription = false
    @State private var showShareSheet = false
    @State private var showSaveConfirmation = false
    @State private var isSaving = false

    var body: some View {
        VStack(spacing: 0) {
            // Image preview
            ScrollView {
                VStack(spacing: AppConstants.spacing24) {
                    if let image = viewModel.processedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(AppConstants.cornerRadiusSmall)
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            .padding()
                    }

                    // Metadata info
                    if let metadata = viewModel.metadata {
                        VStack(alignment: .leading, spacing: AppConstants.spacing12) {
                            if let location = metadata.location {
                                MetadataRow(
                                    icon: "location.fill",
                                    title: "Location",
                                    value: location.formattedCoordinates
                                )
                            }

                            MetadataRow(
                                icon: "clock.fill",
                                title: "Timestamp",
                                value: metadata.formattedTimestamp
                            )

                            if let description = metadata.description, !description.isEmpty {
                                MetadataRow(
                                    icon: "text.alignleft",
                                    title: "Description",
                                    value: description
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }

            // Actions
            VStack(spacing: AppConstants.spacing12) {
                // Save button
                Button(action: saveToLibrary) {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "square.and.arrow.down.fill")
                            Text("Save to Library")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: AppConstants.buttonHeightStandard)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(AppConstants.cornerRadiusMedium)
                    .font(.headline)
                }
                .disabled(isSaving)

                // Share button
                Button(action: { showShareSheet = true }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: AppConstants.buttonHeightStandard)
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(AppConstants.cornerRadiusMedium)
                    .font(.headline)
                }

                // Edit description button
                Button(action: { isEditingDescription = true }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit Description")
                    }
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
                }
                .padding(.vertical, AppConstants.spacing8)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle("Polaroid Photo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                    viewModel.reset()
                }
            }
        }
        .sheet(isPresented: $isEditingDescription) {
            DescriptionEditorView(
                description: $viewModel.photoDescription,
                onSave: {
                    isEditingDescription = false
                    // Re-process with new description
                    Task {
                        if let image = viewModel.originalImage,
                           let metadata = viewModel.metadata {
                            await viewModel.processPhoto(
                                image: image,
                                location: metadata.location.map { CLLocation(
                                    latitude: $0.latitude,
                                    longitude: $0.longitude
                                )},
                                description: viewModel.photoDescription
                            )
                        }
                    }
                }
            )
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = viewModel.processedImage {
                ShareSheet(items: [image])
            }
        }
        .alert("Photo Saved", isPresented: $showSaveConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your Polaroid photo has been saved to your photo library.")
        }
    }

    // MARK: - Actions

    private func saveToLibrary() {
        isSaving = true

        Task {
            do {
                try await viewModel.saveToLibrary()
                showSaveConfirmation = true
            } catch {
                viewModel.error = .saveFailed(error)
            }
            isSaving = false
        }
    }
}

// MARK: - Metadata Row

struct MetadataRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: AppConstants.spacing12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(AppConstants.cornerRadiusSmall)
    }
}

// MARK: - Description Editor

struct DescriptionEditorView: View {
    @Binding var description: String
    let onSave: () -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $description)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.cornerRadiusSmall)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding()

                Spacer()
            }
            .navigationTitle("Edit Description")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

import CoreLocation
