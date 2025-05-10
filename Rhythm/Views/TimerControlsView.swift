//
//  TimerControlsView.swift
//  Rhythm
//
//  Created by Mason Foreman on 2/5/2025.


import SwiftUI

struct TimerControlsView: View {
    let isTimerActive: Bool
    let onStart: () -> Void
    let onPause: () -> Void
    let onReset: () -> Void
    let onSkip: () -> Void

    var body: some View {
        HStack(spacing: 24) {
            Button(action: onReset) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(width: 60, height: 60)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }

            Button(action: {
                isTimerActive ? onPause() : onStart()
            }) {
                Image(systemName: isTimerActive ? "pause.fill" : "play.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(Color.purple)
                    .clipShape(Circle())
            }

            Button(action: onSkip) {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(width: 60, height: 60)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
        }
    }
}




