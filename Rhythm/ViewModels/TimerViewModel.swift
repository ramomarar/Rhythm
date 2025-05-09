//
//  TimerViewModel.swift
//  Rhythm
//
//  Created by Mason Foreman on 2/5/2025.
//
import Foundation
import SwiftUI
import Combine

private var scheduler = PomodoroScheduler()

class TimerViewModel: ObservableObject {
    @Published var timeRemaining: Int = 1500
    @Published var isTimerActive: Bool = false
    @Published var sessionsCompleted: Int = 0
    @Published var currentStreak: Int = 0
    
    private var timer: Timer?
    private var totalTime: Int = 1500
    
    var progress: CGFloat {
        return 1 - CGFloat(timeRemaining) / CGFloat(totalTime)
    }
    
    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var stateTitle: String {
        isTimerActive ? "Focus Time" : "Paused"
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
            timeRemaining = totalTime
        }

        func skipToNext() {
            completeSession()
        }

        private func completeSession() {
            pauseTimer()
            sessionsCompleted += 1
            currentStreak += 1
            resetTimer()
        }

        func handleForegroundTransition() {}
        func handleBackgroundTransition() {
            pauseTimer()
        }
    }
