import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import GoogleSignIn
import FirebaseCore

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
        
        defer {
            isLoading = false
        }
        
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            isAuthenticated = true
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    func signInWithGoogle() async throws {
        isLoading = true
        error = nil
        
        defer {
            isLoading = false
        }
        
        do {
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                throw NSError(domain: "AuthViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase client ID not found"])
            }
            
            // Create Google Sign In configuration object
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            // Get the top view controller to present the Google Sign In UI
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                throw NSError(domain: "AuthViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found"])
            }
            
            // Start the Google Sign In flow
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = result.user.idToken?.tokenString else {
                throw NSError(domain: "AuthViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "No ID token found"])
            }
            
            // Create a Firebase credential with the Google ID token
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: result.user.accessToken.tokenString)
            
            // Sign in to Firebase with the Google credential
            let authResult = try await Auth.auth().signIn(with: credential)
            
            // Create or update user document in Firestore
            try await Firestore.firestore().collection("users").document(authResult.user.uid).setData([
                "email": authResult.user.email ?? "",
                "name": authResult.user.displayName ?? "",
                "updatedAt": Date()
            ], merge: true)
            
            isAuthenticated = true
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    func createAccount(withEmail email: String, password: String, name: String) async throws {
        isLoading = true
        error = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Update the user's display name in Firebase Auth
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()
            
            // Create user document in Firestore
            try await Firestore.firestore().collection("users").document(result.user.uid).setData([
                "email": email,
                "name": name,
                "createdAt": Date()
            ])
            
            isAuthenticated = true
        } catch {
            self.error = error.localizedDescription
            throw error
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
