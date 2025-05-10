//
//  PomodoroScheduler.swift
//  Rhythm
//
//  Created by Mason Foreman on 2/5/2025.
//

import Foundation
import FirebaseAuth
import Combine

class PomodoroScheduler {
    private(set) var completedFocusSessions = 0
    private let sessionService = PomodoroSessionService()
    private var cancellables = Set<AnyCancellable>()
    
    // Default values that will be updated from settings
    private var focusDuration: TimeInterval = 25 * 60
    private var shortBreakDuration: TimeInterval = 5 * 60
    private var longBreakDuration: TimeInterval = 15 * 60
    private var longBreakInterval = 4
    
    private(set) var currentType: SessionType = .focus
    
    init() {
        setupSettingsObserver()
    }
    
    private func setupSettingsObserver() {
        NotificationCenter.default.publisher(for: .pomodoroSettingsDidChange)
            .sink { [weak self] notification in
                guard let self = self,
                      let userInfo = notification.userInfo else { return }
                
                if let focusDuration = userInfo["focusDuration"] as? Int {
                    self.focusDuration = TimeInterval(focusDuration * 60)
                }
                if let shortBreakDuration = userInfo["shortBreakDuration"] as? Int {
                    self.shortBreakDuration = TimeInterval(shortBreakDuration * 60)
                }
                if let longBreakDuration = userInfo["longBreakDuration"] as? Int {
                    self.longBreakDuration = TimeInterval(longBreakDuration * 60)
                }
                if let longBreakInterval = userInfo["longBreakInterval"] as? Int {
                    self.longBreakInterval = longBreakInterval
                }
            }
            .store(in: &cancellables)
    }
    
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

