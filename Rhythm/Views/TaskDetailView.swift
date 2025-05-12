//
//  TaskDetailView.swift
//  Rhythm
//
//  Created by Mason Foreman on 2/5/2025.
//

import SwiftUI

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var taskService: TaskDataService
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var estimatedMinutes: Int = 25
    @State private var dueDate: Date = Date()
    @State private var hasDueDate: Bool = false
    @State private var isCompleted: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    private var isEditing: Bool
    private var taskId: String?
    
    // For creating new tasks
    init(taskService: TaskDataService) {
        self.taskService = taskService
        self.isEditing = false
        self.taskId = nil
    }
    
    // For editing existing tasks
    init(task: TodoTask, taskService: TaskDataService) {
        self.taskService = taskService
        self._title = State(initialValue: task.title)
        self._description = State(initialValue: task.description)
        self._estimatedMinutes = State(initialValue: task.estimatedMinutes)
        self._dueDate = State(initialValue: task.dueDate ?? Date())
        self._hasDueDate = State(initialValue: task.dueDate != nil)
        self._isCompleted = State(initialValue: task.isCompleted)
        self.isEditing = true
        self.taskId = task.id
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section(header: Text("Time Estimate")) {
                    Stepper("\(estimatedMinutes) minutes", value: $estimatedMinutes, in: 5...480, step: 5)
                    
                    if estimatedMinutes > 0 {
                        let sessions = Int(ceil(Double(estimatedMinutes) / Double(UserDefaults.standard.integer(forKey: "focusDuration") > 0 ? UserDefaults.standard.integer(forKey: "focusDuration") : 25)))
                        Text("Estimated \(sessions) focus session\(sessions == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Due Date")) {
                    Toggle("Set Due Date", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                Section {
                    Toggle("Completed", isOn: $isCompleted)
                }
                
                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            performDeleteTask()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Task")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        performSaveTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
    
    private func performSaveTask() {
        isLoading = true
        
        let taskToSave = TodoTask(
            id: taskId ?? UUID().uuidString,
            title: title,
            description: description,
            isCompleted: isCompleted,
            estimatedMinutes: estimatedMinutes,
            dueDate: hasDueDate ? dueDate : nil,
            createdAt: Date(),
            updatedAt: Date(),
            userId: Auth.auth().currentUser?.uid ?? ""
        )
        
        Task {
            do {
                if isEditing {
                    try await taskService.updateTask(taskToSave)
                } else {
                    try await taskService.createTask(taskToSave)
                }
                
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
    
    private func performDeleteTask() {
        guard let id = taskId else { return }
        
        isLoading = true
        
        Task {
            do {
                try await taskService.deleteTask(id)
                
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}



