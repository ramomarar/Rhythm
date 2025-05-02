import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var isLoading = false
    @Published var error: String?
    
    init() {
        self.userSession = Auth.auth().currentUser
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        isLoading = true
        error = nil
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createAccount(withEmail email: String, password: String) async throws {
        isLoading = true
        error = nil
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            // Create user document in Firestore
            try await Firestore.firestore().collection("users").document(result.user.uid).setData([
                "email": email,
                "createdAt": Date()
            ])
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
} 
