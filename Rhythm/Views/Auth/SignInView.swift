import SwiftUI

struct SignInView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome Back")
                        .font(.title)
                        .fontWeight(.bold)
                    
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
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                // Sign In Button
                Button {
                    Task {
                        try await authViewModel.signIn(withEmail: email, password: password)
                    }
                } label: {
                    Text("Sign In")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .disabled(authViewModel.isLoading)
                .opacity(authViewModel.isLoading ? 0.5 : 1)
                
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
                        .foregroundColor(.blue)
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

#Preview {
    SignInView()
        .environmentObject(AuthViewModel())
} 
