//
//  TimerViewModel.swift
//  Rhythm
//
//  Created by Mason Foreman on 2/5/2025.
//
import Foundation
import SwiftUI
import Combine



class TimerViewModel: ObservableObject {
    @Published var timeRemaining: Int
    @Published var isTimerActive: Bool = false
    @Published var sessionsCompleted: Int = 0
    @Published var currentStreak: Int = 0
    @Published var currentSession: Session

    private var timer: Timer?
    private var scheduler = PomodoroScheduler()
    
    var progress: CGFloat {
        return 1 - CGFloat(timeRemaining) / CGFloat(currentSession.duration)
    }

    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var stateTitle: String {
        if isTimerActive {
            switch currentSession.type {
            case .focus: return "Focus Time"
            case .shortBreak: return "Short Break"
            case .longBreak: return "Long Break"
            }
        } else {
            return "Paused"
        }
    }

    init() {
        let session = scheduler.nextSession()
        self.currentSession = session
        self.timeRemaining = Int(session.duration)
    }

    func startTimer() {
        guard !isTimerActive else { return }
        isTimerActive = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.completeSession()
            }
        }
    }

    func pauseTimer() {
        isTimerActive = false
        timer?.invalidate()
    }

    func resetTimer() {
        pauseTimer()
        timeRemaining = Int(currentSession.duration)
    }

    func skipToNext() {
        completeSession()
    }

    private func completeSession() {
        pauseTimer()
        sessionsCompleted += 1
        currentStreak += 1

        let next = scheduler.nextSession()
        currentSession = next
        timeRemaining = Int(next.duration)
    }

    func handleForegroundTransition() {}
    func handleBackgroundTransition() {
        pauseTimer()
    }
}
