//
//  HomeView.swift
//  Rhythm
//
//  Created by Mason Foreman on 2/5/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Foundation

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.gray.opacity(0.2)).ignoresSafeArea()
                ScrollView {
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
                        
                        // Stats Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            // Total Tasks
                            DashboardStatCard(
                                title: "Total Tasks",
                                value: "\(viewModel.totalTasks)",
                                icon: "checklist",
                                color: Color(hex: "#7B61FF"),
                                filter: .all
                            )
                            
                            // Completed This Week
                            DashboardStatCard(
                                title: "Completed",
                                value: "\(viewModel.completedTasks)",
                                icon: "checkmark.circle.fill",
                                color: .green,
                                filter: .completed
                            )
                            
                            // Yet to Complete
                            DashboardStatCard(
                                title: "To Do",
                                value: "\(viewModel.upcomingTasks)",
                                icon: "clock.fill",
                                color: .orange,
                                filter: .active
                            )
                            
                            // Study Time
                            DashboardStatCard(
                                title: "Study Time",
                                value: "\(viewModel.totalStudyTime)m",
                                icon: "timer",
                                color: .blue,
                                filter: nil
                            )
                        }
                        .padding(.horizontal)
                        
                        // Recent/Upcoming Tasks
                        NavigationLink(destination: TaskListView(initialFilter: .active)) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Upcoming Tasks")
                                    .font(.headline)
                                if viewModel.upcomingTaskList.isEmpty {
                                    Text("No upcoming tasks. Enjoy your day!")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                } else {
                                    ForEach(viewModel.upcomingTaskList.prefix(3), id: \.self) { task in
                                        Button(action: {
                                            viewModel.toggleTaskCompletion(task)
                                        }) {
                                            HStack {
                                                Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(task.completed ? .green : .gray)
                                                Text(task.title)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                                Text(task.dueDateString)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            .padding(.vertical, 6)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                        
                        Spacer()
                        // Add Task Button
                        HStack {
                            Spacer()
                            NavigationLink(destination: TaskListView()) {
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
                }
                .navigationTitle("")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gear")
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
    let color: Color
    let filter: TaskFilter?
    
    var body: some View {
        NavigationLink(destination: TaskListView(initialFilter: filter)) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
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
    @Published var totalStudyTime: Int = 0
    @Published var upcomingTaskList: [DashboardTask] = []
    
    private let db = Firestore.firestore()
    
    func loadUserData() {
        guard let user = Auth.auth().currentUser else { return }
        
        // Fetch user data from Firestore
        fetchUserDataAsync(user: user)
        
        // Load tasks from Firestore
        loadTasks()
        
        // Load pomodoro sessions
        loadPomodoroSessions()
    }
    
    private func loadTasks() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("tasks")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self,
                      let documents = snapshot?.documents else { return }
                
                let tasks = documents.compactMap { document -> DashboardTask? in
                    let data = document.data()
                    guard let title = data["title"] as? String,
                          let completed = data["isCompleted"] as? Bool else { return nil }
                    
                    let timestamp = data["dueDate"] as? Timestamp
                    let dueDate = timestamp?.dateValue()
                    
                    return DashboardTask(title: title, completed: completed, dueDate: dueDate)
                }
                
                DispatchQueue.main.async {
                    self.totalTasks = tasks.count
                    self.completedTasks = tasks.filter { $0.completed }.count
                    self.upcomingTaskList = tasks.filter { !$0.completed }
                    self.upcomingTasks = self.upcomingTaskList.count
                }
            }
    }
    
    private func loadPomodoroSessions() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("pomodoro_sessions")
            .whereField("userId", isEqualTo: userId)
            .whereField("completed", isEqualTo: true)
            .whereField("type", isEqualTo: "focus")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self,
                      let documents = snapshot?.documents else { return }
                
                let totalMinutes = documents.reduce(0) { sum, document in
                    let data = document.data()
                    let duration = data["duration"] as? TimeInterval ?? 0
                    return sum + Int(duration / 60)
                }
                
                DispatchQueue.main.async {
                    self.totalStudyTime = totalMinutes
                }
            }
    }
    
    private func fetchUserDataAsync(user: FirebaseAuth.User) {
        DispatchQueue.global().async {
            let db = self.db
            // Create a continuation to bridge between async/await and completion handlers
            do {
                // Use URLSession synchronously as a workaround
                let semaphore = DispatchSemaphore(value: 0)
                var docResult: DocumentSnapshot?
                var docError: Error?
                
                db.collection("users").document(user.uid).getDocument { snapshot, error in
                    docResult = snapshot
                    docError = error
                    semaphore.signal()
                }
                
                semaphore.wait()
                
                if let error = docError {
                    throw error
                }
                
                guard let document = docResult else {
                    DispatchQueue.main.async {
                        self.displayName = user.displayName ?? "User"
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    if document.exists {
                        let data = document.data()
                        self.displayName = data?["name"] as? String ?? "User"
                    } else {
                        self.displayName = user.displayName ?? "User"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.displayName = user.displayName ?? "User"
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
        }
    }
    
    func toggleTaskCompletion(_ task: DashboardTask) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Find the task document
        db.collection("tasks")
            .whereField("userId", isEqualTo: userId)
            .whereField("title", isEqualTo: task.title)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self,
                      let document = snapshot?.documents.first else { return }
                
                // Toggle completion status
                let newStatus = !task.completed
                document.reference.updateData([
                    "isCompleted": newStatus
                ]) { error in
                    if error == nil {
                        // Update local state
                        DispatchQueue.main.async {
                            if let index = self.upcomingTaskList.firstIndex(where: { $0.title == task.title }) {
                                self.upcomingTaskList[index] = DashboardTask(
                                    title: task.title,
                                    completed: newStatus,
                                    dueDate: task.dueDate
                                )
                                self.updateTaskCounts()
                            }
                        }
                    }
                }
            }
    }
    
    private func updateTaskCounts() {
        totalTasks = upcomingTaskList.count
        completedTasks = upcomingTaskList.filter { $0.completed }.count
        upcomingTasks = upcomingTaskList.filter { !$0.completed }.count
    }
}

#Preview {
    HomeView()
}



