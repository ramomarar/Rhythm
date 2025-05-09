//
//  NotificationService.swift
//  Rhythm
//
//  Created by Omar Alkilani on 2/5/2025.
//

import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification auth error: \(error)")
            }
        }
    }

    func scheduleEndSessionNotification(in seconds: TimeInterval, title: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "Session ending soon."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(seconds - AppDurations.notificationLead, 1), repeats: false)
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(req) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
}

