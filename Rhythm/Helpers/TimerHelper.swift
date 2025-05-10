//
//  TimerHelper.swift
//  Rhythm
//
//  Created by Mason Foreman on 2/5/2025.
//

import Foundation
import Combine

class TimerHelper: ObservableObject {
    @Published var timeRemaining: TimeInterval = 0
    @Published var isRunning: Bool = false
    @Published var formattedTime: String = "00:00"
    
    private var timer: AnyCancellable?
    private var startTime: Date?
    private var backgroundTime: Date?
    
    private let timerInterval: TimeInterval = 0.1
    
    init(initialTime: TimeInterval = 0) {
        self.timeRemaining = initialTime
        updateFormattedTime()
    }
    
    
    func start() {
        guard !isRunning else { return }
        
        isRunning = true
        startTime = Date()
        
        timer = Timer.publish(every: timerInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer()
            }
    }
    
    func pause() {
        guard isRunning else { return }
        
        isRunning = false
        timer?.cancel()
        timer = nil
    }
    
    func reset(to time: TimeInterval) {
        pause()
        timeRemaining = time
        updateFormattedTime()
    }
    
    func handleBackgroundTransition() {
        if isRunning {
            backgroundTime = Date()
        }
    }
    
    func handleForegroundTransition() {
        guard isRunning, let backgroundTime = backgroundTime else { return }
        
        let timeInBackground = Date().timeIntervalSince(backgroundTime)
        timeRemaining = max(0, timeRemaining - timeInBackground)
        updateFormattedTime()
        
        if timeRemaining == 0 {
            pause()
        }
    }
    
    
    private func updateTimer() {
        guard let startTime = startTime else { return }
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        timeRemaining = max(0, timeRemaining - elapsedTime)
        updateFormattedTime()
        
        if timeRemaining == 0 {
            pause()
        }
    }
    
    private func updateFormattedTime() {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        formattedTime = String(format: "%02d:%02d", minutes, seconds)
    }
}

extension TimeInterval {
    static func minutes(_ minutes: Int) -> TimeInterval {
        return TimeInterval(minutes * 60)
    }
    
    static func hours(_ hours: Int) -> TimeInterval {
        return TimeInterval(hours * 3600)
    }
}

