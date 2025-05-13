//
//  TimerViewModel.swift
//  Rhythm
//
//  Created by Omar Alkilani on 2/5/2025.
//
import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
class TimerViewModel: ObservableObject {
    @Published var timeRemaining: Int
    @Published var isTimerActive: Bool = false
    @Published var sessionsCompleted: Int = 0
    @Published var currentStreak: Int = 0
    @Published var currentSession: Session
    @Published var error: String?
    @Published var taskProgress: Double = 0

    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private let task: TodoTask?
    
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

    init(task: TodoTask? = nil) {
        self.task = task
        
        self.currentSession = Session(type: .focus, duration: 25 * 60)
        self.timeRemaining = 25 * 60
        
        // Load settings
        if let focusDuration = UserDefaults.standard.object(forKey: "focusDuration") as? Int, focusDuration > 0 {
            self.currentSession = Session(type: .focus, duration: TimeInterval(focusDuration * 60))
            self.timeRemaining = focusDuration * 60
        }
        
        setupSettingsObserver()
    }
    
    private func setupSettingsObserver() {
        NotificationCenter.default.publisher(for: .pomodoroSettingsDidChange)
            .sink { [weak self] notification in
                guard let self = self,
                      let userInfo = notification.userInfo else { return }
                
                let wasActive = self.isTimerActive
                if wasActive {
                    self.pauseTimer()
                }
                
                if let focusDuration = userInfo["focusDuration"] as? Int {
                    self.currentSession = Session(type: .focus, duration: TimeInterval(focusDuration * 60))
                    self.timeRemaining = focusDuration * 60
                }
                
                if wasActive {
                    self.startTimer()
                }
            }
            .store(in: &cancellables)
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
        
        if let task = task {
            // Update task progress
            let sessionLength = UserDefaults.standard.integer(forKey: "focusDuration") > 0 
                ? UserDefaults.standard.integer(forKey: "focusDuration") 
                : 25
            let totalMinutes = task.estimatedMinutes
            let completedMinutes = sessionsCompleted * sessionLength
            taskProgress = min(Double(completedMinutes) / Double(totalMinutes), 1.0)
        }
        
        // Get next session based on current type
        switch currentSession.type {
        case .focus:
            currentSession = Session(type: .shortBreak, duration: 5 * 60)
        case .shortBreak:
            currentSession = Session(type: .focus, duration: 25 * 60)
        case .longBreak:
            currentSession = Session(type: .focus, duration: 25 * 60)
        }
        
        timeRemaining = Int(currentSession.duration)
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
