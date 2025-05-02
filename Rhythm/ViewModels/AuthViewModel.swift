import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    
    init() {
        // Listen for authentication state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        isLoading = true
        error = nil
        
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            isAuthenticated = true
        } catch {
            self.error = error.localizedDescription
            throw error
        } finally {
            isLoading = false
        }
    }
    
    func createAccount(withEmail email: String, password: String) async throws {
        isLoading = true
        error = nil
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            isAuthenticated = true
            
            // Create user document in Firestore
            try await Firestore.firestore().collection("users").document(result.user.uid).setData([
                "email": email,
                "createdAt": Date()
            ])
        } catch {
            self.error = error.localizedDescription
            throw error
        } finally {
            isLoading = false
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
        } catch {
            self.error = error.localizedDescription
        }
    }
} 
