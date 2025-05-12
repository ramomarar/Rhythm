//
//  TaskListView.swift
//  Rhythm
//
//  Created by Mason Foreman on 2/5/2025.
//

import SwiftUI

enum TaskFilter: String, CaseIterable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
    case dueToday = "Due Today"
    case overdue = "Overdue"
}

struct TaskListView: View {
    @StateObject private var taskService = TaskDataService()
    @State private var showingAddTask = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedFilter: TaskFilter = .all
    @State private var showingPomodoro = false
    @State private var selectedTask: TodoTask?
    
    var filteredTasks: [TodoTask] {
        let tasks = taskService.tasks
        switch selectedFilter {
        case .all:
            return tasks
        case .active:
            return tasks.filter { !$0.isCompleted }
        case .completed:
            return tasks.filter { $0.isCompleted }
        case .dueToday:
            return tasks.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return Calendar.current.isDateInToday(dueDate)
            }
        case .overdue:
            return tasks.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return !task.isCompleted && dueDate < Date()
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(TaskFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                if isLoading {
                    ProgressView("Loading tasks...")
                } else if filteredTasks.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No tasks found")
                            .font(.headline)
                        Text("Add a new task to get started")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredTasks) { task in
                            TaskRowView(task: task)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedTask = task
                                }
                        }
                        .onDelete { indexSet in
                            deleteTasksAt(indexSet)
                        }
                    }
                    .refreshable {
                        Task {
                            await loadTasks()
                        }
                    }
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                TaskDetailView(taskService: taskService)
            }
            .sheet(item: $selectedTask) { task in
                TaskDetailView(task: task, taskService: taskService)
            }
            .sheet(isPresented: $showingPomodoro) {
                if let task = selectedTask {
                    PomodoroView(task: task)
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
        .task {
            await loadTasks()
            taskService.observeTasks()
        }
    }
    
    private func loadTasks() async {
        isLoading = true
        do {
            try await taskService.fetchTasks()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func deleteTasksAt(_ indexSet: IndexSet) {
        Task {
            for index in indexSet {
                let task = filteredTasks[index]
                if let id = task.id {
                    do {
                        try await taskService.deleteTask(id)
                    } catch {
                        await MainActor.run {
                            errorMessage = error.localizedDescription
                        }
                    }
                }
            }
        }
    }
}

struct TaskRowView: View {
    let task: TodoTask
    @State private var showingPomodoro = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                Text(task.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                    Text(task.formattedEstimatedTime)
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    if let dueDate = task.dueDate {
                        Image(systemName: "calendar")
                            .foregroundColor(.orange)
                        Text(task.formattedDueDate)
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            if task.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Button(action: { showingPomodoro = true }) {
                    Image(systemName: "timer")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingPomodoro) {
            PomodoroView(task: task)
        }
    }
}



