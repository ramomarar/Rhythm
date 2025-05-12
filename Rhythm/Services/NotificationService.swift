//
//  NotificationService.swift
//  Rhythm
//
//  Created by Omar Alkilani on 2/5/2025.
//

import UserNotifications
import FirebaseFirestore
import FirebaseAuth

final class NotificationService {
    static let shared = NotificationService()
    private init() {}
    private var settings: PomodoroSettings? = nil

    func syncSettings(completion: (() -> Void)? = nil) {
        guard let userId = Auth.auth().currentUser?.uid else { completion?(); return }
        PomodoroSettings.fetch(for: userId) { [weak self] settings in
            self?.settings = settings
            completion?()
        }
    }

    func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification auth error: \(error)")
            }
            completion?(granted)
        }
    }

    func scheduleEndSessionNotification(in seconds: TimeInterval, title: String) {
        guard let settings = settings, settings.notificationsEnabled else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "Session ending soon."
        if settings.soundEnabled {
            content.sound = .default
        }
        // Vibration is handled by system if sound is enabled and device is on vibrate
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(seconds - AppDurations.notificationLead, 1), repeats: false)
        let req = UNNotificationRequest(identifier: "endSessionNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

