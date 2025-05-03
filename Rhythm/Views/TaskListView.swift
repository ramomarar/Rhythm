//
//  TaskListView.swift
//  Rhythm
//
//  Created by Mason Foreman on 2/5/2025.
//

import SwiftUI

struct TaskListView: View {
    @StateObject private var taskService = TaskDataService()
    @State private var showingAddTask = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading tasks...")
                } else {
                    List {
                        ForEach(taskService.tasks) { task in
                            NavigationLink(destination: TaskDetailView(task: task, taskService: taskService)) {
                                TaskRowView(task: task)
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
        _Concurrency.detach {
            for index in indexSet {
                let task = self.taskService.tasks[index]
                if let id = task.id {
                    do {
                        try await self.taskService.deleteTask(id)
                    } catch {
                        await MainActor.run {
                            self.errorMessage = error.localizedDescription
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
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                Text(task.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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



