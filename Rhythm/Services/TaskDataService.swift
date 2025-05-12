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
    case encodingError(String)
    case decodingError(String)
    case networkError(String)
    case unauthorized
    case unknown(String)
    
    var localizedDescription: String {
        switch self {
        case .encodingError(let message):
            return "Failed to encode task data: \(message)"
        case .decodingError(let message):
            return "Failed to decode task data: \(message)"
        case .networkError(let message):
            return "Network error occurred: \(message)"
        case .unauthorized:
            return "User is not authorized"
        case .unknown(let message):
            return "An unknown error occurred: \(message)"
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
            DispatchQueue.main.async {
                self.error = .unauthorized
            }
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
        } catch let error as EncodingError {
            DispatchQueue.main.async {
                self.error = .encodingError(error.localizedDescription)
            }
            throw TaskError.encodingError(error.localizedDescription)
        } catch {
            DispatchQueue.main.async {
                self.error = .unknown(error.localizedDescription)
            }
            throw TaskError.unknown(error.localizedDescription)
        }
    }
    
    // MARK: - Read Tasks
    func fetchTasks() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.error = .unauthorized
            }
            throw TaskError.unauthorized
        }
        
        do {
            let snapshot = try await db.collection(tasksCollection)
                .whereField("userId", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let decodedTasks = try snapshot.documents.compactMap { document in
                var taskDict = document.data()
                taskDict["id"] = document.documentID
                let data = try JSONSerialization.data(withJSONObject: taskDict)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    // Try to decode as Firestore Timestamp first
                    if let timestamp = try? container.decode(Timestamp.self) {
                        return timestamp.dateValue()
                    }
                    // Try to decode as Double (UNIX timestamp)
                    if let timeInterval = try? container.decode(Double.self) {
                        return Date(timeIntervalSince1970: timeInterval)
                    }
                    // Try to decode as Int (UNIX timestamp)
                    if let timeInterval = try? container.decode(Int.self) {
                        return Date(timeIntervalSince1970: Double(timeInterval))
                    }
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date")
                }
                return try decoder.decode(TodoTask.self, from: data)
            }
            DispatchQueue.main.async {
                self.tasks = decodedTasks
            }
        } catch let error as DecodingError {
            DispatchQueue.main.async {
                self.error = .decodingError(error.localizedDescription)
            }
            throw TaskError.decodingError(error.localizedDescription)
        } catch {
            DispatchQueue.main.async {
                self.error = .unknown(error.localizedDescription)
            }
            throw TaskError.unknown(error.localizedDescription)
        }
    }
    
    // MARK: - Update Task
    func updateTask(_ task: TodoTask) async throws {
        guard let taskId = task.id else {
            DispatchQueue.main.async {
                self.error = .unknown("Task ID is missing")
            }
            throw TaskError.unknown("Task ID is missing")
        }
        
        var updatedTask = task
        updatedTask.updatedAt = Date()
        
        do {
            let data = try JSONEncoder().encode(updatedTask)
            let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            try await db.collection(tasksCollection).document(taskId).setData(dict)
        } catch let error as EncodingError {
            DispatchQueue.main.async {
                self.error = .encodingError(error.localizedDescription)
            }
            throw TaskError.encodingError(error.localizedDescription)
        } catch {
            DispatchQueue.main.async {
                self.error = .unknown(error.localizedDescription)
            }
            throw TaskError.unknown(error.localizedDescription)
        }
    }
    
    // MARK: - Delete Task
    func deleteTask(_ taskId: String) async throws {
        do {
            try await db.collection(tasksCollection).document(taskId).delete()
        } catch {
            DispatchQueue.main.async {
                self.error = .networkError(error.localizedDescription)
            }
            throw TaskError.networkError(error.localizedDescription)
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
                    self?.error = .networkError(error?.localizedDescription ?? "Unknown network error")
                    return
                }
                
                do {
                    let decodedTasks = try documents.compactMap { document in
                        var taskDict = document.data()
                        taskDict["id"] = document.documentID
                        let data = try JSONSerialization.data(withJSONObject: taskDict)
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .custom { decoder in
                            let container = try decoder.singleValueContainer()
                            // Try to decode as Firestore Timestamp first
                            if let timestamp = try? container.decode(Timestamp.self) {
                                return timestamp.dateValue()
                            }
                            // Try to decode as Double (UNIX timestamp)
                            if let timeInterval = try? container.decode(Double.self) {
                                return Date(timeIntervalSince1970: timeInterval)
                            }
                            // Try to decode as Int (UNIX timestamp)
                            if let timeInterval = try? container.decode(Int.self) {
                                return Date(timeIntervalSince1970: Double(timeInterval))
                            }
                            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date")
                        }
                        return try decoder.decode(TodoTask.self, from: data)
                    }
                    DispatchQueue.main.async {
                        self?.tasks = decodedTasks
                    }
                } catch {
                    DispatchQueue.main.async {
                        self?.error = .decodingError(error.localizedDescription)
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
