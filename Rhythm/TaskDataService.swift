import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

// MARK: - Task Model
struct Task: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date
    var userId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case isCompleted
        case createdAt
        case updatedAt
        case userId
    }
}

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
    
    @Published var tasks: [Task] = []
    @Published var error: TaskError?
    
    // MARK: - Create Task
    func createTask(_ task: Task) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw TaskError.unauthorized
        }
        
        var newTask = task
        newTask.userId = userId
        newTask.createdAt = Date()
        newTask.updatedAt = Date()
        
        do {
            try await db.collection(tasksCollection).addDocument(from: newTask)
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
                try document.data(as: Task.self)
            }
        } catch {
            throw TaskError.decodingError
        }
    }
    
    // MARK: - Update Task
    func updateTask(_ task: Task) async throws {
        guard let taskId = task.id else {
            throw TaskError.unknown
        }
        
        var updatedTask = task
        updatedTask.updatedAt = Date()
        
        do {
            try await db.collection(tasksCollection).document(taskId).setData(from: updatedTask)
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
                    try? document.data(as: Task.self)
                }
            }
    }
    
    // MARK: - Helper Methods
    func toggleTaskCompletion(_ task: Task) async throws {
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