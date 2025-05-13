import Foundation
import FirebaseFirestore
import FirebaseAuth

class PomodoroSessionService: ObservableObject {
    private let db = Firestore.firestore()
    private let sessionsCollection = "pomodoro_sessions"
    
    @Published var sessions: [Session] = []
    @Published var error: String?
    
    func saveSession(_ session: Session, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let _ = Auth.auth().currentUser?.uid else {
            let error = NSError(domain: "PomodoroSessionService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
            completion(.failure(error))
            return
        }
        
        do {
            let sessionData = session
            let data = try JSONEncoder().encode(sessionData)
            guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                let error = NSError(domain: "PomodoroSessionService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize session data"])
                completion(.failure(error))
                return
            }
            
            db.collection(sessionsCollection).document(session.id.uuidString).setData(dict) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchSessions(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.success(()))
            return
        }
        
        db.collection(sessionsCollection)
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success(()))
                    return
                }
                
                do {
                    let fetchedSessions = try documents.compactMap { document -> Session? in
                        var sessionDict = document.data()
                        sessionDict["id"] = document.documentID
                        let data = try JSONSerialization.data(withJSONObject: sessionDict)
                        return try JSONDecoder().decode(Session.self, from: data)
                    }
                    
                    self?.sessions = fetchedSessions
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            }
    }
    
    func observeSessions() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection(sessionsCollection)
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    self?.error = error?.localizedDescription
                    return
                }
                
                self?.sessions = documents.compactMap { document in
                    var sessionDict = document.data()
                    sessionDict["id"] = document.documentID
                    do {
                        let data = try JSONSerialization.data(withJSONObject: sessionDict)
                        return try JSONDecoder().decode(Session.self, from: data)
                    } catch {
                        return nil
                    }
                }
            }
    }
} 
