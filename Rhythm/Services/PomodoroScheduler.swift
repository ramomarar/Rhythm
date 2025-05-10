//
//  PomodoroScheduler.swift
//  Rhythm
//
//  Created by Mason Foreman on 2/5/2025.
//

import Foundation
import FirebaseAuth

class PomodoroScheduler {
    private(set) var completedFocusSessions = 0
    private let sessionService = PomodoroSessionService()
    
    //the configurablel session durations (in seconds so 25 * 60 is 25 mins etc )
    let focusDuration: TimeInterval = 25 * 60
    let shortBreakDuration: TimeInterval = 5 * 60
    let longBreakDuration: TimeInterval = 15 * 60
    let longBreakInterval = 4
    
    private(set) var currentType: SessionType = .focus
    
    func getNextSession(completion: @escaping (Session) -> Void) {
        let nextType: SessionType
        
        switch currentType {
        case .focus:
            completedFocusSessions += 1
            nextType = (completedFocusSessions % longBreakInterval == 0) ? .longBreak : .shortBreak
        case .shortBreak, .longBreak:
            nextType = .focus
        }
        
        currentType = nextType
        
        let duration: TimeInterval
        switch nextType {
        case .focus: duration = focusDuration
        case .shortBreak: duration = shortBreakDuration
        case .longBreak: duration = longBreakDuration
        }
        
        let session = Session(type: nextType, duration: duration)
        
        if let userId = Auth.auth().currentUser?.uid {
            var sessionWithUser = session
            sessionWithUser.userId = userId
            sessionService.saveSession(sessionWithUser) { _ in
                // Ignore result, just complete with the session
                completion(session)
            }
        } else {
            completion(session)
        }
    }
    
    func fetchSessions(completion: @escaping (Result<Void, Error>) -> Void) {
        sessionService.fetchSessions { result in
            completion(result)
        }
    }
    
    func observeSessions() {
        sessionService.observeSessions()
    }
}

