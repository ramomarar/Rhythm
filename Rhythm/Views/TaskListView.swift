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
    @State private var selectedFilter: TaskFilter
    @State private var showingPomodoro = false
    @State private var selectedTask: TodoTask?
    @State private var showingTaskDetail = false
    @State private var pomodoroTask: TodoTask? = nil
    @State private var pomodoroTriggered = false
    
    init(initialFilter: TaskFilter? = nil) {
        _selectedFilter = State(initialValue: initialFilter ?? .all)
    }
    
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
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(TaskFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                if !taskService.isInitialized || isLoading {
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
                                    if let latestTask = taskService.tasks.first(where: { $0.id == task.id }) {
                                        selectedTask = latestTask
                                    } else {
                                        selectedTask = task
                                    }
                                    showingTaskDetail = true
                                }
                        }
                        .onDelete { indexSet in
                            deleteTasksAt(indexSet)
                        }
                    }
                    .refreshable {
                        await loadTasks()
                    }
                }
            }
            .navigationBarTitle("Tasks", displayMode: .inline)
            .navigationBarItems(trailing: 
                Button(action: { showingAddTask = true }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingAddTask) {
                TaskDetailView(taskService: taskService)
            }
            .sheet(item: $selectedTask) { task in
                TaskDetailSheet(
                    task: task,
                    taskService: taskService,
                    onStartPomodoro: {
                        var taskCopy = task
                        
                        if let id = task.id {
                            taskCopy.id = id
                        }
                        
                        pomodoroTask = taskCopy
                        pomodoroTriggered = true
                        
                        selectedTask = nil
                    }
                )
            }
            .onChange(of: selectedTask) { oldValue, newValue in
                if newValue == nil && pomodoroTriggered {
                    pomodoroTriggered = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showingPomodoro = true
                    }
                }
            }
            .fullScreenCover(isPresented: $showingPomodoro) {
                ZStack {
                    if let task = pomodoroTask {
                        PomodoroView(task: task, taskService: taskService)
                            .onAppear {
                            }
                            .onDisappear {
                            }
                    } else {
                        VStack(spacing: 16) {
                            Text("No task selected for Pomodoro")
                                .font(.headline)
                            
                            Button("Close") {
                                showingPomodoro = false
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding()
                        .onAppear {
                        }
                    }
                }
                .interactiveDismissDisabled()
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
        .task {
            await loadTasks()
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
                    
                    if task.dueDate != nil {
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
            }
        }
        .padding(.vertical, 4)
    }
}

struct TaskDetailSheet: View {
    let task: TodoTask
    let taskService: TaskDataService
    @State private var showingEditSheet = false
    let onStartPomodoro: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title and Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text(task.title)
                            .font(.title)
                            .fontWeight(.bold)
                        Text(task.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Task Details
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(icon: "clock", title: "Estimated Time", value: task.formattedEstimatedTime)
                        if task.dueDate != nil {
                            DetailRow(icon: "calendar", title: "Due Date", value: task.formattedDueDate)
                        }
                        DetailRow(icon: "checkmark.circle", title: "Status", value: task.isCompleted ? "Completed" : "Active")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            onStartPomodoro()
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "timer")
                                Text("Start Pomodoro Session")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(taskService.isInitialized ? Color(hex: "#7B61FF") : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!taskService.isInitialized)
                        
                        if !taskService.isInitialized {
                            ProgressView("Loading task data...")
                        }
                        
                        Button(action: { showingEditSheet = true }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Task")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                TaskDetailView(task: task, taskService: taskService)
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}



