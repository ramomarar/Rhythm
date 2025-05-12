//
//  Date+Extensions.swift
//  Rhythm
//
//  Created Omar Alkilani on 2/5/2025.
//

import Foundation

extension Date {
    /// Formats a Date into a human-readable timer string (MM:SS)
    func timerString() -> String {
        let interval = Int(self.timeIntervalSince1970)
        let minutes = (interval / 60) % 60
        let seconds = interval % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Formats a Date for display in task lists (e.g. Apr 21, 14:30)
    func displayString() -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: self)
    }
}
