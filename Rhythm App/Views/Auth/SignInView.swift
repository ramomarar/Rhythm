import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    
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
                        try await viewModel.signIn(withEmail: email, password: password)
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
                .disabled(viewModel.isLoading)
                .opacity(viewModel.isLoading ? 0.5 : 1)
                
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
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") { viewModel.error = nil }
            } message: {
                Text(viewModel.error ?? "")
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
} 