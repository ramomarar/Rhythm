//
//  Session.swift
//  Rhythm
//
//  Created by Mason Foreman on 2/5/2025.
//
import Foundation

enum SessionType: String, Codable {
    case focus
    case shortBreak
    case longBreak
}

struct Session: Identifiable, Codable {
    let id: UUID
    let type: SessionType
    let duration: TimeInterval
    let timestamp: Date
    var userId: String?
    var completed: Bool
    
    init(type: SessionType, duration: TimeInterval) {
        self.id = UUID()
        self.type = type
        self.duration = duration
        self.timestamp = Date()
        self.completed = false
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case duration
        case timestamp
        case userId
        case completed
    }
}

