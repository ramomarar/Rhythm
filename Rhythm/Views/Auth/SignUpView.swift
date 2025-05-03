import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
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
                    Text("Sign Up")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#7B61FF"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Create Account")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
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
                PrimaryButton(title: "Sign Up", action: {
                    signUpUser()
                }, isLoading: authViewModel.isLoading)
                
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
                    .foregroundColor(Color(hex: "#7B61FF"))
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
    
    private func signUpUser() {
        _Concurrency.detach {
            do {
                try await self.authViewModel.createAccount(withEmail: self.email, password: self.password, name: self.name)
                await MainActor.run {
                    self.dismiss()
                }
            } catch {
                // Error is already handled by the alert in the view
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
} 