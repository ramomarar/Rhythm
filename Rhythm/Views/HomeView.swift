//
//  HomeView.swift
//  Rhythm
//
//  Created by Mason Foreman on 2/5/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    // User Info Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Welcome!")
                            .font(.title)
                            .bold()
                        if let user = Auth.auth().currentUser {
                            Text("Email: \(user.email ?? "No email")")
                                .font(.subheadline)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Example Data Section
                    if !viewModel.exampleData.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Example Data from Firestore")
                                .font(.headline)
                            ForEach(viewModel.exampleData.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                HStack {
                                    Text(key)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("\(String(describing: value))")
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        viewModel.signOut()
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadUserData()
        }
    }
}

class HomeViewModel: ObservableObject {
    @Published var exampleData: [String: Any] = [:]
    @Published var isLoading = true
    
    private let db = Firestore.firestore()
    
    func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                if let document = document, document.exists {
                    self?.exampleData = document.data() ?? [:]
                } else {
                    // If document doesn't exist, create initial data
                    self?.createInitialUserData(userId: userId)
                }
                self?.isLoading = false
            }
        }
    }
    
    private func createInitialUserData(userId: String) {
        let exampleData: [String: Any] = [
            "createdAt": Timestamp(),
            "lastLogin": Timestamp(),
            "exampleTasks": [
                [
                    "title": "Example Task 1",
                    "completed": false,
                    "createdAt": Timestamp()
                ],
                [
                    "title": "Example Task 2",
                    "completed": true,
                    "createdAt": Timestamp()
                ]
            ],
            "settings": [
                "notifications": true,
                "darkMode": false
            ]
        ]
        
        db.collection("users").document(userId).setData(exampleData) { [weak self] error in
            if let error = error {
                print("Error creating user data: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self?.exampleData = exampleData
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

#Preview {
    HomeView()
}



