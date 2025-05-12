//
//  Constants.swift
//  Rhythm
//
//  Created by Omar Alkilani on 2/5/2025.
//

import SwiftUI
import FirebaseFirestore

enum AppColors {
    static let primary       = Color("Primary")
    static let accent        = Color("Accent")
    static let background    = Color("Background")
    static let text          = Color("Text")
}

enum AppDurations {
    static let pomodoro      = 25 * 60.0       // seconds
    static let shortBreak    = 5 * 60.0
    static let longBreak     = 15 * 60.0
    static let notificationLead = 5.0           // notify 5 seconds before end
}

struct PomodoroDefaults {
    static let focusDuration: TimeInterval = 25 * 60
    static let shortBreak: TimeInterval = 5 * 60
    static let longBreak: TimeInterval = 15 * 60
    static let longBreakInterval: Int = 4
}

struct PomodoroSettings {
    let focusDuration: TimeInterval
    let shortBreak: TimeInterval
    let longBreak: TimeInterval
    let longBreakInterval: Int
    let notificationsEnabled: Bool
    let soundEnabled: Bool
    let vibrationEnabled: Bool

    static func fetch(for userId: String, completion: @escaping (PomodoroSettings) -> Void) {
        let ref = Firestore.firestore().collection("pomodoro_settings").document(userId)
        ref.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                completion(PomodoroSettings(
                    focusDuration: PomodoroDefaults.focusDuration,
                    shortBreak: PomodoroDefaults.shortBreak,
                    longBreak: PomodoroDefaults.longBreak,
                    longBreakInterval: PomodoroDefaults.longBreakInterval,
                    notificationsEnabled: true,
                    soundEnabled: true,
                    vibrationEnabled: true
                ))
                return
            }
            completion(PomodoroSettings(
                focusDuration: (data["focusDuration"] as? Double ?? PomodoroDefaults.focusDuration * 1.0) * 60,
                shortBreak: (data["shortBreakDuration"] as? Double ?? PomodoroDefaults.shortBreak * 1.0) * 60,
                longBreak: (data["longBreakDuration"] as? Double ?? PomodoroDefaults.longBreak * 1.0) * 60,
                longBreakInterval: data["longBreakInterval"] as? Int ?? PomodoroDefaults.longBreakInterval,
                notificationsEnabled: data["notificationsEnabled"] as? Bool ?? true,
                soundEnabled: data["soundEnabled"] as? Bool ?? true,
                vibrationEnabled: data["vibrationEnabled"] as? Bool ?? true
            ))
        }
    }
}
