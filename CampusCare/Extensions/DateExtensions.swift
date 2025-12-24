//
//  DateExtensions.swift
//  CampusCare
//
//  Created on 24/12/2025.
//

import Foundation
import FirebaseFirestore

/*
 USAGE EXAMPLES:
 
 // ============================================
 // Date Extensions
 // ============================================
 
 // 1. Time ago display (relative time)
 let date = Date()
 let timeAgo = date.timeAgoDisplay()
 print(timeAgo) // "just now" or "2 hours ago" or "3 days ago"
 
 // 2. Readable string (default: medium date, short time)
 let readable = date.toReadableString()
 print(readable) // "Dec 24, 2025 at 3:30 PM"
 
 // 3. Readable string with custom styles
 let customFormat = date.toReadableString(dateStyle: .long, timeStyle: .none)
 print(customFormat) // "December 24, 2025"
 
 let shortFormat = date.toReadableString(dateStyle: .short, timeStyle: .medium)
 print(shortFormat) // "12/24/25, 3:30:45 PM"
 
 // ============================================
 // Firebase Timestamp Extensions
 // ============================================
 
 // 1. Timestamp to readable string
 let timestamp = Timestamp(date: Date())
 let timestampReadable = timestamp.toReadableString()
 print(timestampReadable) // "Dec 24, 2025 at 3:30 PM"
 
 // 2. Timestamp with custom styles
 let customTimestamp = timestamp.toReadableString(dateStyle: .full, timeStyle: .short)
 print(customTimestamp) // "Tuesday, December 24, 2025 at 3:30 PM"
 
 // 3. Timestamp to time ago
 let timestampAgo = timestamp.timeAgoDisplay()
 print(timestampAgo) // "just now" or "5 minutes ago"
 
 // ============================================
 // Real-world Usage in ViewControllers
 // ============================================
 
 // Example: Display request date in a table cell
 let request = RequestModel(...)
 cell.dateLabel.text = request.releaseDate.timeAgoDisplay() // "2 hours ago"
 
 // Example: Display formatted date in detail view
 let formattedDate = request.releaseDate.toReadableString()
 detailLabel.text = "Submitted on \(formattedDate)"
 
 // Example: Display assigned date with custom format
 if let assignedDate = request.assignedDate {
     let dateOnly = assignedDate.toReadableString(dateStyle: .medium, timeStyle: .none)
     assignedLabel.text = "Assigned: \(dateOnly)"
 }
 
 */

extension Date {
    /// Converts a Date to a "time ago" display format (e.g., "2 hours ago", "3 days ago")
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    /// Formats the date to a readable string with medium date and short time style
    /// Example: "Dec 24, 2025 at 3:30 PM"
    func toReadableString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    /// Formats the date to a readable string with custom date and time styles
    func toReadableString(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }
}

extension Timestamp {
    /// Converts a Firebase Timestamp to a readable Date string
    /// Example: "Dec 24, 2025 at 3:30 PM"
    func toReadableString() -> String {
        return self.dateValue().toReadableString()
    }
    
    /// Converts a Firebase Timestamp to a readable Date string with custom styles
    func toReadableString(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        return self.dateValue().toReadableString(dateStyle: dateStyle, timeStyle: timeStyle)
    }
    
    /// Converts a Firebase Timestamp to a "time ago" display format
    func timeAgoDisplay() -> String {
        return self.dateValue().timeAgoDisplay()
    }
}
