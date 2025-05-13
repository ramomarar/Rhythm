//
//  PomodoroView.swift
//  Rhythm
//

//

import SwiftUI

struct PomodoroView: View {
    @StateObject private var viewModel: TimerViewModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss
    
    let task: TodoTask
    let taskService: TaskDataService
    
    init(task: TodoTask, taskService: TaskDataService) {
        self.task = task
        self.taskService = taskService
        _viewModel = StateObject(wrappedValue: TimerViewModel(task: task))
    }

    var body: some View {
        if task.estimatedMinutes <= 0 || task.title.isEmpty {
            VStack(spacing: 16) {
                Text("Invalid Task Data").font(.title)
                Text("Title: \(task.title)")
                Text("Estimated Minutes: \(task.estimatedMinutes)")
                Text("userId: \(task.userId)")
                Text("id: \(task.id ?? "nil")")
                Text("If you see this, your task data is broken or missing.")
            }.padding()
            .onAppear {
            }
        } else {
            NavigationView {
                VStack(spacing: 24) {
                    VStack(spacing: 6) {
                        Text("Current Task")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(task.title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                        Text(task.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal)
                        Text("Estimated \(task.estimatedSessions) session\(task.estimatedSessions == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(viewModel.stateTitle)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                            .frame(width: 220, height: 220)

                        Circle()
                            .trim(from: 0, to: viewModel.progress)
                            .stroke(Color(hex: "#7B61FF"), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                            .frame(width: 220, height: 220)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear, value: viewModel.progress)

                        VStack(spacing: 8) {
                            Text(viewModel.formattedTime)
                                .font(.system(size: 46, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)

                            Text("\(viewModel.sessionsCompleted) sessions completed")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)

                    TimerControlsView(
                        isTimerActive: viewModel.isTimerActive,
                        onStart: { viewModel.startTimer() },
                        onPause: { viewModel.pauseTimer() },
                        onReset: { viewModel.resetTimer() },
                        onSkip: { viewModel.skipToNext() }
                    )

                    HStack(spacing: 32) {
                        StatView(title: "Current Streak", value: "\(viewModel.currentStreak)")
                        StatView(title: "Session Type", value: viewModel.currentSession.type.rawValue.capitalized)
                    }
                    .padding(.top, 16)
                    
                    Button(action: {
                        // Mark task as completed when all estimated sessions are done
                        if viewModel.sessionsCompleted >= task.estimatedSessions {
                            Task {
                                var updatedTask = task
                                updatedTask.isCompleted = true
                                try? await taskService.updateTask(updatedTask)
                            }
                        }
                        dismiss()
                    }) {
                        Text("Complete Task")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                    .disabled(viewModel.sessionsCompleted < task.estimatedSessions)
                    .opacity(viewModel.sessionsCompleted >= task.estimatedSessions ? 1 : 0.5)
                    .padding(.top, 16)
                }
                .padding()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
                .onChange(of: scenePhase) { phase in
                    switch phase {
                    case .active:
                        viewModel.handleForegroundTransition()
                    case .inactive:
                        viewModel.handleBackgroundTransition()
                    default:
                        break
                    }
                }
                .onAppear {
                    if !viewModel.isTimerActive {
                        viewModel.startTimer()
                    }
                }
                .onDisappear {
                }
                .alert("Error", isPresented: Binding(
                    get: { viewModel.error != nil },
                    set: { if !$0 { viewModel.error = nil } }
                )) {
                    Button("OK") { viewModel.error = nil }
                } message: {
                    Text(viewModel.error ?? "")
                }
            }
            .interactiveDismissDisabled(true)
        }
    }
}

struct StatView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    PomodoroView(
        task: TodoTask(
            id: "preview-id",
            title: "Sample Task",
            description: "This is a sample task",
            isCompleted: false,
            estimatedMinutes: 50,
            dueDate: Date(),
            createdAt: Date(),
            updatedAt: Date(),
            userId: "preview-user"
        ),
        taskService: TaskDataService()
    )
}
