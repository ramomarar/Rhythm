import SwiftUI

struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .textFieldStyle(.plain)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

struct AuthTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AuthTextField(placeholder: "Regular Text Field", text: .constant(""))
            AuthTextField(placeholder: "Secure Text Field", text: .constant(""), isSecure: true)
        }
        .padding()
        .background(Color(.systemGray6))
    }
} 