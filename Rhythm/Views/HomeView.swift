//
//  HomeView.swift
//  Rhythm
//
//  Created by Mason Foreman on 2/5/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                VStack(alignment: .leading, spacing: 24) {
                    // Greeting
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome back,")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(viewModel.displayName)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(hex: "#7B61FF"))
                    }
                    .padding(.top, 16)
                    .padding(.horizontal)
                    
                    // Quick Stats Card
                    HStack(spacing: 16) {
                        DashboardStatCard(title: "Tasks", value: "\(viewModel.totalTasks)", icon: "checklist")
                        DashboardStatCard(title: "Completed", value: "\(viewModel.completedTasks)", icon: "checkmark.circle.fill")
                        DashboardStatCard(title: "Upcoming", value: "\(viewModel.upcomingTasks)", icon: "clock.fill")
                    }
                    .padding(.horizontal)
                    
                    // Recent/Upcoming Tasks
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Upcoming Tasks")
                            .font(.headline)
                        if viewModel.upcomingTaskList.isEmpty {
                            Text("No upcoming tasks. Enjoy your day!")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        } else {
                            ForEach(viewModel.upcomingTaskList.prefix(3), id: \.self) { task in
                                HStack {
                                    Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(task.completed ? .green : .gray)
                                    Text(task.title)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text(task.dueDateString)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    Spacer()
                    // Add Task Button
                    HStack {
                        Spacer()
                        Button(action: {
                            // TODO: Present add task view
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Task")
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .background(Color(hex: "#7B61FF"))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 24)
                }
                .navigationTitle("")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Logout") {
                            viewModel.signOut()
                        }
                    }
                }
            }
            .onAppear {
                viewModel.loadUserData()
            }
        }
    }
}

struct DashboardStatCard: View {
    let title: String
    let value: String
    let icon: String
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(hex: "#7B61FF"))
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 90, height: 90)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

struct DashboardTask: Hashable {
    let title: String
    let completed: Bool
    let dueDate: Date?
    var dueDateString: String {
        guard let dueDate = dueDate else { return "No date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: dueDate)
    }
}

class HomeViewModel: ObservableObject {
    @Published var displayName: String = "User"
    @Published var totalTasks: Int = 0
    @Published var completedTasks: Int = 0
    @Published var upcomingTasks: Int = 0
    @Published var upcomingTaskList: [DashboardTask] = []
    
    private let db = Firestore.firestore()
    
    func loadUserData() {
        guard let user = Auth.auth().currentUser else { return }
        displayName = user.displayName ?? "User"
        // Simulate loading tasks (replace with Firestore fetch in real app)
        let now = Date()
        let tasks = [
            DashboardTask(title: "Finish onboarding UI", completed: false, dueDate: now.addingTimeInterval(3600)),
            DashboardTask(title: "Review dashboard design", completed: false, dueDate: now.addingTimeInterval(7200)),
            DashboardTask(title: "Submit assignment", completed: true, dueDate: now.addingTimeInterval(-3600)),
        ]
        totalTasks = tasks.count
        completedTasks = tasks.filter { $0.completed }.count
        upcomingTaskList = tasks.filter { !$0.completed }
        upcomingTasks = upcomingTaskList.count
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

#Preview {
    HomeView()
}



