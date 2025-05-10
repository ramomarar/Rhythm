//
//  TimerViewModel.swift
//  Rhythm
//
//  Created by Mason Foreman on 2/5/2025.
//
import Foundation
import SwiftUI
import Combine
import FirebaseAuth

@MainActor
class TimerViewModel: ObservableObject {
    @Published var timeRemaining: Int
    @Published var isTimerActive: Bool = false
    @Published var sessionsCompleted: Int = 0
    @Published var currentStreak: Int = 0
    @Published var currentSession: Session
    @Published var error: String?

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
        let session = Session(type: .focus, duration: 25 * 60)
        self.currentSession = session
        self.timeRemaining = Int(session.duration)
        
        loadData()
    }
    
    private func loadData() {
        scheduler.fetchSessions { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.scheduler.observeSessions()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                }
            }
        }
    }

    func startTimer() {
        guard !isTimerActive else { return }
        isTimerActive = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func updateTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            completeCurrentSession()
        }
    }

    func pauseTimer() {
        isTimerActive = false
        timer?.invalidate()
        timer = nil
    }

    func resetTimer() {
        pauseTimer()
        timeRemaining = Int(currentSession.duration)
    }

    func skipToNext() {
        completeCurrentSession()
    }
    
    private func completeCurrentSession() {
        pauseTimer()
        sessionsCompleted += 1
        currentStreak += 1
        
        var completedSession = currentSession
        completedSession.completed = true
        
        getNextSession()
    }
    
    private func getNextSession() {
        scheduler.getNextSession { [weak self] nextSession in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.currentSession = nextSession
                self.timeRemaining = Int(nextSession.duration)
            }
        }
    }

    func handleForegroundTransition() {
        if isTimerActive {
            startTimer()
        }
    }
    
    func handleBackgroundTransition() {
        pauseTimer()
    }
}
