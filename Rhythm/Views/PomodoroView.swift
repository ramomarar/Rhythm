
//
//  PomodoroView.swift
//  Rhythm
//

//

import SwiftUI

struct PomodoroView: View {
    @StateObject private var viewModel = TimerViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(spacing: 32) {
            Text(viewModel.stateTitle)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 250, height: 250)

                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(Color(hex: "#7B61FF"), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear, value: viewModel.progress)

                VStack(spacing: 8) {
                    Text(viewModel.formattedTime)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text("\(viewModel.sessionsCompleted) sessions completed")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

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
            .padding(.top, 32)
        }
        .padding()
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                viewModel.handleForegroundTransition()
            case .background:
                viewModel.handleBackgroundTransition()
            default:
                break
            }
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
    PomodoroView()
}
