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
    
    @State private var title: String
    @State private var description: String
    @State private var isCompleted: Bool
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private var isEditing: Bool
    private var taskId: String?
    
    // For creating new tasks
    init(taskService: TaskDataService) {
        self.taskService = taskService
        self._title = State(initialValue: "")
        self._description = State(initialValue: "")
        self._isCompleted = State(initialValue: false)
        self.isEditing = false
        self.taskId = nil
    }
    
    // For editing existing tasks
    init(task: TodoTask, taskService: TaskDataService) {
        self.taskService = taskService
        self._title = State(initialValue: task.title)
        self._description = State(initialValue: task.description)
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
            .alert(isPresented: .constant(errorMessage != nil)) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage ?? ""),
                    dismissButton: .default(Text("OK")) {
                        errorMessage = nil
                    }
                )
            }
        }
    }
    
    private func performSaveTask() {
        isLoading = true
        
        let taskToSave = TodoTask(
            id: taskId,
            title: title,
            description: description,
            isCompleted: isCompleted,
            createdAt: Date(),
            updatedAt: Date(),
            userId: ""
        )
        
        _Concurrency.detach {
            do {
                if self.isEditing {
                    try await self.taskService.updateTask(taskToSave)
                } else {
                    try await self.taskService.createTask(taskToSave)
                }
                
                await MainActor.run {
                    self.isLoading = false
                    self.dismiss()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func performDeleteTask() {
        guard let id = taskId else { return }
        
        isLoading = true
        
        _Concurrency.detach {
            do {
                try await self.taskService.deleteTask(id)
                
                await MainActor.run {
                    self.isLoading = false
                    self.dismiss()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}



