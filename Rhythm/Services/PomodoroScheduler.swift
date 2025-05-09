//
//  PomodoroScheduler.swift
//  Rhythm
//
//  Created by Mason Foreman on 2/5/2025.
//

import Foundation

class PomodoroScheduler {
    private(set) var completedFocusSessions = 0
    
    //the configurablel session durations (in seconds so 25 * 60 is 25 mins etc )
    let focusDuration: TimeInterval = 25 * 60
    let shortBreakDuration: TimeInterval = 5 * 60
    let longBreakDuration: TimeInterval = 15 * 60
    let longBreakInterval = 4
    
    private(set) var currentType: SessionType = .focus
    
    func nextSession() -> Session {
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
        
        return Session(type: nextType, duration: duration)
    }
    
    
    
    
    
}

