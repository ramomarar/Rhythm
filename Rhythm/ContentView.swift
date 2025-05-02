//
//  ContentView.swift
//  Rhythm
//
//  Created by Mason Foreman on 2/5/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                HomeView()
            } else {
                AuthLandingView()
            }
        }
    }
}

#Preview {
    ContentView()
}
