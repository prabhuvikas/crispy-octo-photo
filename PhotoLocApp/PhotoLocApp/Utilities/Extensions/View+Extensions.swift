//
//  View+Extensions.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import SwiftUI

extension View {
    /// Apply standard card style
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(AppConstants.cornerRadiusMedium)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }

    /// Apply primary button style
    func primaryButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.buttonHeightStandard)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(AppConstants.cornerRadiusMedium)
            .font(.headline)
    }

    /// Apply secondary button style
    func secondaryButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.buttonHeightStandard)
            .background(Color(.systemGray5))
            .foregroundColor(.primary)
            .cornerRadius(AppConstants.cornerRadiusMedium)
            .font(.headline)
    }

    /// Hide keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    /// Conditional modifier
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
