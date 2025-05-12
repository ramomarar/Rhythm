//
//  SettingsView.swift
//  Rhythm
//
//  Created by Mason Foreman on 2/5/2025.
//

import SwiftUI
import FirebaseFirestore

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Timer Durations")) {
                    Picker("Focus Duration", selection: $viewModel.focusDuration) {
                        ForEach([15, 20, 25, 30, 35, 40, 45, 50, 55, 60], id: \.self) { minutes in
                            Text("\(minutes) minutes").tag(minutes)
                        }
                    }
                    
                    Picker("Short Break", selection: $viewModel.shortBreakDuration) {
                        ForEach([3, 5, 7, 10, 15], id: \.self) { minutes in
                            Text("\(minutes) minutes").tag(minutes)
                        }
                    }
                    
                    Picker("Long Break", selection: $viewModel.longBreakDuration) {
                        ForEach([10, 15, 20, 25, 30], id: \.self) { minutes in
                            Text("\(minutes) minutes").tag(minutes)
                        }
                    }
                    
                    Picker("Sessions until Long Break", selection: $viewModel.longBreakInterval) {
                        ForEach([2, 3, 4, 5, 6], id: \.self) { count in
                            Text("\(count) sessions").tag(count)
                        }
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $viewModel.notificationsEnabled)
                    if viewModel.notificationsEnabled {
                        Toggle("Sound Alerts", isOn: $viewModel.soundEnabled)
                        Toggle("Vibration", isOn: $viewModel.vibrationEnabled)
                    }
                }
                
                Section {
                    Button("Reset to Defaults") {
                        viewModel.resetToDefaults()
                    }
                    .foregroundColor(.red)
                }
                
                Section {
                    Button(role: .destructive) {
                        authViewModel.signOut()
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                        }
                    }
                }
            }
            .navigationTitle("Timer Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.saveSettings()
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") { viewModel.error = nil }
            } message: {
                Text(viewModel.error ?? "")
            }
        }
    }
}

#Preview {
    SettingsView()
}



