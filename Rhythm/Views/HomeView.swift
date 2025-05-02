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
            ZStack {
                Color.white.ignoresSafeArea()
                VStack(spacing: 24) {
                    // Decorative Dots
                    HStack {
                        Circle().fill(Color(hex: "#FFD36E").opacity(0.25)).frame(width: 12, height: 12)
                        Spacer()
                        Circle().fill(Color(hex: "#7B61FF").opacity(0.15)).frame(width: 10, height: 10)
                    }.padding(.horizontal, 8)
                    
                    // Onboarding Image & Bubble
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#E5DEFF"))
                            .frame(width: 180, height: 180)
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(Color(hex: "#7B61FF"))
                        // Example chat bubbles
                        VStack {
                            HStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .frame(width: 90, height: 36)
                                    .overlay(
                                        HStack(spacing: 4) {
                                            Image(systemName: "person.2.fill").font(.caption)
                                            Text("...").font(.caption)
                                        }
                                        .foregroundColor(Color(hex: "#7B61FF"))
                                    )
                                    .offset(x: -40, y: -40)
                                Spacer()
                            }
                            Spacer()
                            HStack {
                                Spacer()
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .frame(width: 110, height: 36)
                                    .overlay(
                                        HStack(spacing: 4) {
                                            Image(systemName: "bubble.left.fill").font(.caption)
                                            Text("...").font(.caption)
                                        }
                                        .foregroundColor(Color(hex: "#7B61FF"))
                                    )
                                    .offset(x: 40, y: 40)
                            }
                        }
                        .frame(width: 180, height: 180)
                    }
                    .padding(.top, 16)
                    
                    // Welcome Text
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task Management")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "#7B61FF"))
                        Text("Manage your ")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                        + Text("Tasks")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(hex: "#7B61FF"))
                        + Text(" quickly for\nResults✌️")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
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
                        .cornerRadius(16)
                    }
                    Spacer()
                    // Bottom Navigation
                    HStack {
                        Button("Skip") {
                            // Handle skip
                        }
                        .foregroundColor(.gray)
                        Spacer()
                        Button(action: {
                            // Handle next/onboard
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#7B61FF"))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.white)
                                    .font(.system(size: 22, weight: .bold))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .padding()
                .navigationTitle("")
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



