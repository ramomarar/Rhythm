//
//  Task.swift
//  Rhythm
//
//  Created by Mason Foreman on 2/5/2025.
//

import Foundation
import FirebaseFirestore

struct TodoTask: Identifiable, Codable {
    var id: String?
    var title: String
    var description: String
    var isCompleted: Bool
    var estimatedMinutes: Int
    var dueDate: Date?
    var createdAt: Date
    var updatedAt: Date
    var userId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case isCompleted
        case estimatedMinutes
        case dueDate
        case createdAt
        case updatedAt
        case userId
    }
    
    // Computed property to calculate estimated sessions based on user preferences
    var estimatedSessions: Int {
        // Default to 25 minutes if no preference is set
        let sessionLength = UserDefaults.standard.integer(forKey: "focusDuration") > 0 
            ? UserDefaults.standard.integer(forKey: "focusDuration") 
            : 25
        return Int(ceil(Double(estimatedMinutes) / Double(sessionLength)))
    }
    
    // Formatted due date string
    var formattedDueDate: String {
        guard let dueDate = dueDate else { return "No due date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: dueDate)
    }
    
    // Formatted estimated time
    var formattedEstimatedTime: String {
        let hours = estimatedMinutes / 60
        let minutes = estimatedMinutes % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}


