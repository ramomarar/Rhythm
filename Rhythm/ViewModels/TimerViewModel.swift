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
import XCTest

  @testable import Rhythm
  
  @MainActor
class TimerViewModel: ObservableObject {
    @Published var timeRemaining: Int
    @Published var isTimerActive: Bool = false
    @Published var sessionsCompleted: Int = 0
    @Published var currentStreak: Int = 0
    @Published var currentSession: Session
    @Published var error: String?

class TimerViewModelTests: XCTestCase {
    var vm: TimerViewModel!

    override func setUp() {
        super.setUp()
        vm = TimerViewModel()
    }

    func testStartPomodoroSetsRemaining() {
        vm.startPomodoro()
        XCTAssertEqual(vm.remainingTime, AppDurations.pomodoro)
        XCTAssertTrue(vm.isRunning)
    }

    func testPauseStopsTimer() {
        vm.startPomodoro()
        vm.pause()
        XCTAssertFalse(vm.isRunning)
    }

    func testResetClearsTimer() {
        vm.startPomodoro()
        vm.reset()
        XCTAssertEqual(vm.remainingTime, 0)
        XCTAssertFalse(vm.isRunning)
    }
}  
  private var timer: Timer?
    private var scheduler = PomodoroScheduler()
    private var cancellables = Set<AnyCancellable>()
    
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
        // Initialize with temporary values that will be updated
        self.currentSession = Session(type: .focus, duration: 25 * 60)
        self.timeRemaining = 25 * 60
        
        setupSettingsObserver()
        loadData()
        
        // Load initial settings
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("pomodoro_settings").document(userId).getDocument { [weak self] snapshot, error in
            guard let self = self,
                  let data = snapshot?.data() else { return }
            
            let focusDuration = data["focusDuration"] as? Int ?? 25
            self.currentSession = Session(type: .focus, duration: TimeInterval(focusDuration * 60))
            self.timeRemaining = focusDuration * 60
        }
    }
    
    private func setupSettingsObserver() {
        NotificationCenter.default.publisher(for: .pomodoroSettingsDidChange)
            .sink { [weak self] notification in
                guard let self = self,
                      let userInfo = notification.userInfo else { return }
                
                // Store current timer state
                let wasActive = self.isTimerActive
                
                // Pause timer if it's running
                if wasActive {
                    self.pauseTimer()
                }
                
                // Update session duration based on current type
                switch self.currentSession.type {
                case .focus:
                    if let focusDuration = userInfo["focusDuration"] as? Int {
                        self.currentSession = Session(type: .focus, duration: TimeInterval(focusDuration * 60))
                        self.timeRemaining = focusDuration * 60
                    }
                case .shortBreak:
                    if let shortBreakDuration = userInfo["shortBreakDuration"] as? Int {
                        self.currentSession = Session(type: .shortBreak, duration: TimeInterval(shortBreakDuration * 60))
                        self.timeRemaining = shortBreakDuration * 60
                    }
                case .longBreak:
                    if let longBreakDuration = userInfo["longBreakDuration"] as? Int {
                        self.currentSession = Session(type: .longBreak, duration: TimeInterval(longBreakDuration * 60))
                        self.timeRemaining = longBreakDuration * 60
                    }
                }
                
                // Restart timer if it was running
                if wasActive {
                    self.startTimer()
                }
            }
            .store(in: &cancellables)
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
