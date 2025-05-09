//
//  Theme.swift
//  Rhythm
//
//  Created by Omar Alkilani on 2/5/2025.
//

import SwiftUI

struct AppColorTheme {
    let primary: Color
    let accent: Color
    let background: Color
    let text: Color

    /// Light-mode theme (uses the light appearance of each asset)
    static let light = AppColorTheme(
        primary: Color("Primary"),
        accent:  Color("Accent"),
        background: Color("Background"),
        text:      Color("Text")
    )

    /// Dark-mode theme (uses the dark appearance of each asset)
    static let dark = AppColorTheme(
        primary: Color("Primary"),
        accent:  Color("Accent"),
        background: Color("Background"),
        text:      Color("Text")
    )
}

// MARK: - Environment Key
private struct AppColorThemeKey: EnvironmentKey {
    static let defaultValue: AppColorTheme = .light
}

extension EnvironmentValues {
    /// Access the current color theme via @Environment(\.colorTheme)
    var colorTheme: AppColorTheme {
        get { self[AppColorThemeKey.self] }
        set { self[AppColorThemeKey.self] = newValue }
    }
}

// MARK: - Theme Provider
/// Wrap your root view in this provider to automatically inject light/dark themes.
struct AppColorThemeProvider<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .environment(\.colorTheme, colorScheme == .dark ? .dark : .light)
    }
}
