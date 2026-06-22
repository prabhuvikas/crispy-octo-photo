//
//  LoadingView.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import SwiftUI

/// Loading indicator view
struct LoadingView: View {
    let message: String

    init(message: String = "Processing...") {
        self.message = message
    }

    var body: some View {
        VStack(spacing: AppConstants.spacing16) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))

            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding(AppConstants.spacing32)
        .background(
            RoundedRectangle(cornerRadius: AppConstants.cornerRadiusMedium)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

/// Full-screen loading overlay
struct LoadingOverlay: View {
    let message: String

    init(message: String = "Processing...") {
        self.message = message
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            LoadingView(message: message)
        }
    }
}
