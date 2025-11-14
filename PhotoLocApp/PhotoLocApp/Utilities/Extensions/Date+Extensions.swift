//
//  Date+Extensions.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import Foundation

extension Date {
    /// Format as "Dec 15, 2023 • 2:30 PM"
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    /// Format as "Dec 15, 2023"
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    /// Format as "2:30 PM"
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    /// Format as "2023-12-15_14-30-45" for filenames
    var filenameTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter.string(from: self)
    }
}
