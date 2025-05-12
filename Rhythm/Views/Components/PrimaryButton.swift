import SwiftUI

struct PrimaryButton: View {
    let title: String
    var action: () -> Void
    var isLoading: Bool = false
    var disabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "#7B61FF"), Color(hex: "#A084FF")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color(hex: "#7B61FF").opacity(0.2), radius: 8, x: 0, y: 4)
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
        }
        .disabled(disabled || isLoading)
        .opacity((disabled || isLoading) ? 0.5 : 1)
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PrimaryButton(title: "Sign In", action: {})
            PrimaryButton(title: "Sign Up", action: {}, isLoading: true)
        }
        .padding()
        .background(.gray.opacity(0.2))
    }
} 
