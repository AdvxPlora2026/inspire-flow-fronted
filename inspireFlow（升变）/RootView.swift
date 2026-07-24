import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: AppSession

    @Binding var hasCompletedOnboarding: Bool

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                StartView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .transition(.opacity)
            } else if !session.isAuthenticated {
                LoginView()
                    .transition(.opacity)
            } else if session.role == .creator && session.needsCreatorProfileSetup && !session.isDemoMode {
                CreatorProfileSetupView(mode: .registration)
                    .transition(.opacity)
            } else {
                roleDestination
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: hasCompletedOnboarding)
        .animation(.easeOut(duration: 0.2), value: session.isAuthenticated)
        .animation(.easeOut(duration: 0.2), value: session.needsCreatorProfileSetup)
        .animation(.easeOut(duration: 0.2), value: session.role)
    }

    @ViewBuilder
    private var roleDestination: some View {
        switch session.role {
        case .creator:
            CreatorMainView()
        case .client:
            ClientMainView()
        }
    }
}

#Preview {
    RootView(hasCompletedOnboarding: .constant(true))
        .environmentObject(AppSession())
        .environmentObject(AppStore())
}