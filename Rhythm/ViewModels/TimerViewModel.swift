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
