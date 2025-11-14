//
//  CameraView.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import SwiftUI

/// SwiftUI wrapper for UIKit CameraViewController
struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.onPhotoCaptured = { image in
            capturedImage = image
            presentationMode.wrappedValue.dismiss()
        }
        controller.onCancel = {
            presentationMode.wrappedValue.dismiss()
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // No updates needed
    }
}
