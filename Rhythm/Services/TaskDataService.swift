//
//  TaskDataService.swift
//  Rhythm
//
//  Created by Mason Foreman on 2/5/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - Task Error
enum TaskError: Error {
    case encodingError
    case decodingError
    case networkError
    case unauthorized
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .encodingError:
            return "Failed to encode task data"
        case .decodingError:
            return "Failed to decode task data"
        case .networkError:
            return "Network error occurred"
        case .unauthorized:
            return "User is not authorized"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Task Data Service
class TaskDataService: ObservableObject {
    private let db = Firestore.firestore()
    private let tasksCollection = "tasks"
    
    @Published var tasks: [TodoTask] = []
    @Published var error: TaskError?
    
    // MARK: - Create Task
    func createTask(_ task: TodoTask) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw TaskError.unauthorized
        }
        
        var newTask = task
        newTask.userId = userId
        newTask.createdAt = Date()
        newTask.updatedAt = Date()
        
        do {
            let data = try JSONEncoder().encode(newTask)
            let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            try await db.collection(tasksCollection).addDocument(data: dict)
        } catch {
            throw TaskError.encodingError
        }
    }
    
    // MARK: - Read Tasks
    func fetchTasks() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw TaskError.unauthorized
        }
        
        do {
            let snapshot = try await db.collection(tasksCollection)
                .whereField("userId", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            self.tasks = try snapshot.documents.compactMap { document in
                var taskDict = document.data()
                taskDict["id"] = document.documentID
                let data = try JSONSerialization.data(withJSONObject: taskDict)
                let decoder = JSONDecoder()
                return try decoder.decode(TodoTask.self, from: data)
            }
        } catch {
            throw TaskError.decodingError
        }
    }
    
    // MARK: - Update Task
    func updateTask(_ task: TodoTask) async throws {
        guard let taskId = task.id else {
            throw TaskError.unknown
        }
        
        var updatedTask = task
        updatedTask.updatedAt = Date()
        
        do {
            let data = try JSONEncoder().encode(updatedTask)
            let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            try await db.collection(tasksCollection).document(taskId).setData(dict)
        } catch {
            throw TaskError.encodingError
        }
    }
    
    // MARK: - Delete Task
    func deleteTask(_ taskId: String) async throws {
        do {
            try await db.collection(tasksCollection).document(taskId).delete()
        } catch {
            throw TaskError.networkError
        }
    }
    
    // MARK: - Real-time Updates
    func observeTasks() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection(tasksCollection)
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    self?.error = .networkError
                    return
                }
                
                self?.tasks = documents.compactMap { document in
                    var taskDict = document.data()
                    taskDict["id"] = document.documentID
                    do {
                        let data = try JSONSerialization.data(withJSONObject: taskDict)
                        let decoder = JSONDecoder()
                        return try decoder.decode(TodoTask.self, from: data)
                    } catch {
                        return nil
                    }
                }
            }
    }
    
    // MARK: - Helper Methods
    func toggleTaskCompletion(_ task: TodoTask) async throws {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        try await updateTask(updatedTask)
    }
    
    func deleteAllTasks() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw TaskError.unauthorized
        }
        
        let snapshot = try await db.collection(tasksCollection)
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
} 
