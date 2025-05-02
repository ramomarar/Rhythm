import SwiftUI

struct OnboardingPage {
    let image: String // systemName
    let title: String
    let subtitle: String
}

struct AuthLandingView: View {
    @State private var currentPage = 0
    @State private var showSignIn = false
    @State private var showSignUp = false
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            image: "rectangle.stack.fill.badge.person.crop",
            title: "Rhythm\nOrganize Your Student Life",
            subtitle: "Stay on top of classes, assignments, and deadlines with Rhythm."
        ),
        OnboardingPage(
            image: "bubble.left.and.bubble.right.fill",
            title: "Let's create a space for your studies.",
            subtitle: "Academic Management"
        ),
        OnboardingPage(
            image: "person.3.sequence.fill",
            title: "Study smarter and stay organized 👌",
            subtitle: "Academic Management"
        ),
        OnboardingPage(
            image: "checkmark.seal.fill",
            title: "Track your tasks and ace your goals ✌️",
            subtitle: "Academic Management"
        )
    ]
    
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            VStack {
                Spacer()
                // Illustration
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.1))
                        .frame(width: 220, height: 220)
                    Image(systemName: pages[currentPage].image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(Color(hex: "#7B61FF"))
                }
                .padding(.bottom, 24)
                // Subtitle (above title)
                if !pages[currentPage].subtitle.isEmpty {
                    Text(pages[currentPage].subtitle)
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#7B61FF"))
                        .padding(.bottom, 4)
                }
                // Title
                Text(pages[currentPage].title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
                // Page Indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \ .self) { idx in
                        Circle()
                            .fill(idx == currentPage ? Color(hex: "#7B61FF") : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 24)
                // Navigation Buttons
                HStack {
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            currentPage = pages.count - 1
                        }
                        .foregroundColor(.gray)
                    }
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button(action: { currentPage += 1 }) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#7B61FF"))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.white)
                                    .font(.system(size: 22, weight: .bold))
                            }
                        }
                    } else {
                        Button(action: { showSignIn = true }) {
                            Text("Get Started")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "#7B61FF").cornerRadius(16))
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .sheet(isPresented: $showSignIn) {
                SignInView()
            }
            .sheet(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
}

#Preview {
    AuthLandingView()
} 