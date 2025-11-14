//
//  ErrorView.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import SwiftUI

/// Error display view
struct ErrorView: View {
    let error: AppError
    let onRetry: (() -> Void)?
    let onDismiss: () -> Void

    init(error: AppError, onRetry: (() -> Void)? = nil, onDismiss: @escaping () -> Void) {
        self.error = error
        self.onRetry = onRetry
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack(spacing: AppConstants.spacing24) {
            // Error icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            // Title
            Text(error.title)
                .font(.title2)
                .fontWeight(.bold)

            // Message
            Text(error.message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Recovery suggestion
            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.vertical, AppConstants.spacing8)
                    .background(
                        RoundedRectangle(cornerRadius: AppConstants.cornerRadiusSmall)
                            .fill(Color(.systemGray6))
                    )
            }

            // Action buttons
            VStack(spacing: AppConstants.spacing12) {
                if let onRetry = onRetry {
                    Button(action: onRetry) {
                        Text("Retry")
                            .frame(maxWidth: .infinity)
                            .frame(height: AppConstants.buttonHeightStandard)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(AppConstants.cornerRadiusMedium)
                            .font(.headline)
                    }
                }

                Button(action: onDismiss) {
                    Text("Dismiss")
                        .frame(maxWidth: .infinity)
                        .frame(height: AppConstants.buttonHeightStandard)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(AppConstants.cornerRadiusMedium)
                        .font(.headline)
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

/// Error alert modifier
struct ErrorAlert: ViewModifier {
    @Binding var error: AppError?

    func body(content: Content) -> some View {
        content
            .alert(item: $error) { error in
                Alert(
                    title: Text(error.title),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
    }
}

extension View {
    func errorAlert(_ error: Binding<AppError?>) -> some View {
        modifier(ErrorAlert(error: error))
    }
}
