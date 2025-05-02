import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Create Account")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Please enter your information and\ncreate your account")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top)
            
            // Form Fields
            VStack(spacing: 16) {
                AuthTextField(placeholder: "Name", text: $name)
                    .textContentType(.name)
                
                AuthTextField(placeholder: "Email", text: $email)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                
                AuthTextField(placeholder: "Password", text: $password, isSecure: true)
                    .textContentType(.newPassword)
            }
            
            // Sign Up Button
            Button {
                Task {
                    do {
                        try await authViewModel.createAccount(withEmail: email, password: password)
                        dismiss()
                    } catch {
                        // Error is already handled by the alert in the view
                    }
                }
            } label: {
                Text("Sign Up")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(authViewModel.isLoading)
            .opacity(authViewModel.isLoading ? 0.5 : 1)
            
            // Sign up with providers
            VStack(spacing: 16) {
                Text("Sign up with")
                    .foregroundColor(.gray)
                
                HStack(spacing: 20) {
                    Button {
                        // Handle Apple sign up
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
                        // Handle Google sign up
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
            
            // Sign In Link
            HStack {
                Text("Have an Account?")
                    .foregroundColor(.gray)
                
                Button("Sign In") {
                    dismiss()
                }
                .foregroundColor(.blue)
            }
            .font(.footnote)
        }
        .padding()
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
            }
        }
        .alert("Error", isPresented: .constant(authViewModel.error != nil)) {
            Button("OK") { authViewModel.error = nil }
        } message: {
            Text(authViewModel.error ?? "")
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
} 