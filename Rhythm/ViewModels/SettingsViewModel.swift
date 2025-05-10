//
//  SettingsViewModel.swift
//  Rhythm
//
//  Created by Mason Foreman on 2/5/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var focusDuration: Int = 25
    @Published var shortBreakDuration: Int = 5
    @Published var longBreakDuration: Int = 15
    @Published var longBreakInterval: Int = 4
    @Published var notificationsEnabled: Bool = true
    @Published var soundEnabled: Bool = true
    @Published var vibrationEnabled: Bool = true
    @Published var error: String?
    
    private let db = Firestore.firestore()
    private let settingsCollection = "pomodoro_settings"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSettings()
        setupSettingsObserver()
    }
    
    private func setupSettingsObserver() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection(settingsCollection).document(userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.error = error.localizedDescription
                    return
                }
                
                if let data = snapshot?.data() {
                    self.updateSettingsFromData(data)
                }
            }
    }
    
    private func updateSettingsFromData(_ data: [String: Any]) {
        focusDuration = data["focusDuration"] as? Int ?? 25
        shortBreakDuration = data["shortBreakDuration"] as? Int ?? 5
        longBreakDuration = data["longBreakDuration"] as? Int ?? 15
        longBreakInterval = data["longBreakInterval"] as? Int ?? 4
        notificationsEnabled = data["notificationsEnabled"] as? Bool ?? true
        soundEnabled = data["soundEnabled"] as? Bool ?? true
        vibrationEnabled = data["vibrationEnabled"] as? Bool ?? true
        
        // Notify PomodoroScheduler of changes
        NotificationCenter.default.post(
            name: .pomodoroSettingsDidChange,
            object: nil,
            userInfo: [
                "focusDuration": focusDuration,
                "shortBreakDuration": shortBreakDuration,
                "longBreakDuration": longBreakDuration,
                "longBreakInterval": longBreakInterval
            ]
        )
    }
    
    func loadSettings() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection(settingsCollection).document(userId).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                self.error = error.localizedDescription
                return
            }
            
            if let data = snapshot?.data() {
                self.updateSettingsFromData(data)
            } else {
                // If no settings exist, create default settings
                self.saveSettings()
            }
        }
    }
    
    func saveSettings() {
        guard let userId = Auth.auth().currentUser?.uid else {
            error = "User not authenticated"
            return
        }
        
        let settings: [String: Any] = [
            "focusDuration": focusDuration,
            "shortBreakDuration": shortBreakDuration,
            "longBreakDuration": longBreakDuration,
            "longBreakInterval": longBreakInterval,
            "notificationsEnabled": notificationsEnabled,
            "soundEnabled": soundEnabled,
            "vibrationEnabled": vibrationEnabled,
            "lastUpdated": Date()
        ]
        
        db.collection(settingsCollection).document(userId).setData(settings) { [weak self] error in
            if let error = error {
                self?.error = error.localizedDescription
            }
        }
    }
    
    func resetToDefaults() {
        focusDuration = 25
        shortBreakDuration = 5
        longBreakDuration = 15
        longBreakInterval = 4
        notificationsEnabled = true
        soundEnabled = true
        vibrationEnabled = true
        saveSettings()
    }
}

extension Notification.Name {
    static let pomodoroSettingsDidChange = Notification.Name("pomodoroSettingsDidChange")
}



