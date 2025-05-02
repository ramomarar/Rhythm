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
    init(task: Task, taskService: TaskDataService) {
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
                            Task {
                                await deleteTask()
                            }
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
                        Task {
                            await saveTask()
                        }
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
    
    private func saveTask() async {
        isLoading = true
        
        let task = Task(
            id: taskId,
            title: title,
            description: description,
            isCompleted: isCompleted,
            createdAt: Date(),
            updatedAt: Date(),
            userId: ""
        )
        
        do {
            if isEditing {
                try await taskService.updateTask(task)
            } else {
                try await taskService.createTask(task)
            }
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func deleteTask() async {
        guard let id = taskId else { return }
        
        isLoading = true
        do {
            try await taskService.deleteTask(id)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
} 