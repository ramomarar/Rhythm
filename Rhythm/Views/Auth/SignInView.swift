import SwiftUI

struct SignInView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                VStack(spacing: 32) {
                    // Decorative Dots
                    HStack {
                        Circle().fill(Color(hex: "#7B61FF").opacity(0.15)).frame(width: 10, height: 10)
                        Spacer()
                        Circle().fill(Color(hex: "#FFD36E").opacity(0.25)).frame(width: 8, height: 8)
                    }.padding(.horizontal, 8)
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sign In")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "#7B61FF"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Welcome Back")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                        Text("Please enter your email address\nand password for Login")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        AuthTextField(placeholder: "Email", text: $email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                        AuthTextField(placeholder: "Password", text: $password, isSecure: true)
                            .textContentType(.password)
                        Button("Forgot Password?") {
                            // Handle forgot password
                        }
                        .font(.footnote)
                        .foregroundColor(Color(hex: "#7B61FF"))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                    // Sign In Button
                    PrimaryButton(title: "Sign In", action: {
                        signInUser()
                    }, isLoading: authViewModel.isLoading)
                    
                    // Sign in with providers
                    VStack(spacing: 16) {
                        Text("Sign in with")
                            .foregroundColor(.gray)
                        HStack(spacing: 20) {
                            Button {
                                // Handle Apple sign in
                            } label: {
                                Image(systemName: "apple.logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .clipShape(Circle())
                            }
                            Button {
                                // Handle Google sign in
                            } label: {
                                Image("google_logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    Spacer()
                    // Sign Up Link
                    HStack {
                        Text("Not Registered Yet?")
                            .foregroundColor(.gray)
                        NavigationLink("Sign Up", destination: SignUpView())
                            .foregroundColor(Color(hex: "#7B61FF"))
                    }
                    .font(.footnote)
                }
                .padding()
                .navigationBarBackButtonHidden()
                .alert("Error", isPresented: .constant(authViewModel.error != nil)) {
                    Button("OK") { authViewModel.error = nil }
                } message: {
                    Text(authViewModel.error ?? "")
                }
            }
        }
    }
    
    private func signInUser() {
        // Create a detached task that won't cause conflicts
        _Concurrency.detach {
            do {
                try await self.authViewModel.signIn(withEmail: self.email, password: self.password)
            } catch {
                // Error handling is managed by AuthViewModel
            }
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthViewModel())
} 
