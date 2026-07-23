import SwiftUI

enum AppTheme {
    static let background = Color(red: 0.025, green: 0.027, blue: 0.032)
    static let surface = Color.white.opacity(0.06)
    static let border = Color.white.opacity(0.12)
    static let muted = Color.white.opacity(0.58)
}

struct AppBackground<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            LinearGradient(
                colors: [Color.cyan.opacity(0.08), .clear],
                startPoint: .topTrailing,
                endPoint: .center
            )
            .ignoresSafeArea()

            content
        }
    }
}

struct AppCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(AppTheme.border)
            }
    }
}

struct ProjectSummaryCard: View {
    let project: CreatorProject
    let action: () -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(project.name)
                            .font(.headline)
                        Label(project.kind.title, systemImage: project.kind == .commercial ? "briefcase.fill" : "person.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(project.stage.title)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.08), in: Capsule())
                }

                Text(project.initialIdea)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                ProgressView(value: project.stage.progress)
                    .tint(.white)

                if project.stage != .settled {
                    Button(project.stage.actionTitle, action: action)
                        .buttonStyle(.bordered)
                        .tint(.white)
                        .font(.caption.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }
}