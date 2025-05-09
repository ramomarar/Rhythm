//
//  AppNavigation.swift
//  Rhythm
//
//  Created by Omar Alkilani on 2/5/2025.
//

import SwiftUI

struct AppNavigation: View {
    @EnvironmentObject var taskVM: TaskViewModel
    @EnvironmentObject var timerVM: TimerViewModel

    var body: some View {
        TabView {
            NavigationStack {
                TasksView()
                    .navigationTitle("Tasks")
            }
            .tabItem {
                Label("Tasks", systemImage: "list.bullet")
            }
            .environmentObject(taskVM)

            NavigationStack {
                TimerView()
                    .navigationTitle("Timer")
            }
            .tabItem {
                Label("Timer", systemImage: "timer")
            }
            .environmentObject(timerVM)

            NavigationStack {
                StatsView()
                    .navigationTitle("Stats")
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar")
            }
            .environmentObject(taskVM)
        }
        .accentColor(AppColorThemeProvider().content().environment(
            \ .colorScheme, .light
        ).colorTheme.accent) // Ensure accent uses theme's accent color
        .background(
            Color.clear // background is handled by individual views
        )
    }
}

// Preview
struct AppNavigation_Previews: PreviewProvider {
    static var previews: some View {
        AppColorThemeProvider {
            AppNavigation()
                .environmentObject(TaskViewModel())
                .environmentObject(TimerViewModel())
        }
        .preferredColorScheme(.light)

        AppColorThemeProvider {
            AppNavigation()
                .environmentObject(TaskViewModel())
                .environmentObject(TimerViewModel())
        }
        .preferredColorScheme(.dark)
    }
}

