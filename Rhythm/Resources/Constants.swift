//
//  Constants.swift
//  Rhythm
//
//  Created by Omar Alkilani on 2/5/2025.
//

import SwiftUI

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
