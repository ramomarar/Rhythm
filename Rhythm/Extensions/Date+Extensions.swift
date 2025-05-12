//
//  Date+Extensions.swift
//  Rhythm
//
//  Created Omar Alkilani on 2/5/2025.
//

import Foundation

extension TimeInterval {
    /// Formats a TimeInterval (seconds) into MM:SS
    func timerString() -> String {
        let totalSeconds = Int(self)
        let minutes = (totalSeconds / 60) % 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension Date {
    /// Formats a Date for display in task/session lists (e.g. Apr 21, 14:30)
    func displayString() -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: self)
    }
    /// Formats a Date for compact display (e.g. 14:30)
    func timeString() -> String {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        return df.string(from: self)
    }
}
