import SwiftUI

enum AppTheme {
    static let background = Color(red: 0.018, green: 0.019, blue: 0.022)
    static let elevatedBackground = Color(red: 0.045, green: 0.047, blue: 0.052)
    static let surface = Color.white.opacity(0.065)
    static let emphasizedSurface = Color.white.opacity(0.1)
    static let border = Color.white.opacity(0.14)
    static let muted = Color.white.opacity(0.56)
    static let subdued = Color.white.opacity(0.36)
    static let cornerRadius: CGFloat = 8
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
                colors: [Color.white.opacity(0.055), .clear, Color.black.opacity(0.24)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Canvas { context, size in
                let spacing: CGFloat = 28
                var path = Path()

                stride(from: CGFloat.zero, through: size.width, by: spacing).forEach { x in
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }

                stride(from: CGFloat.zero, through: size.height, by: spacing).forEach { y in
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }

                context.stroke(path, with: .color(.white.opacity(0.018)), lineWidth: 0.5)
            }
            .ignoresSafeArea()
            .accessibilityHidden(true)

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
            .background(.thinMaterial, in: cardShape)
            .background(AppTheme.surface, in: cardShape)
            .overlay {
                cardShape
                    .strokeBorder(AppTheme.border)
            }
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
    }
}

struct AppBrandMark: View {
    var compact = false

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.white)

                Image(systemName: "arrow.up.right")
                    .font(.system(size: compact ? 11 : 14, weight: .black))
                    .foregroundStyle(.black)
            }
            .frame(width: compact ? 28 : 36, height: compact ? 28 : 36)

            VStack(alignment: .leading, spacing: 0) {
                Text("升变")
                    .font((compact ? Font.subheadline : .headline).weight(.bold))
                Text("PAWN")
                    .font(.caption2.monospaced().weight(.semibold))
                    .foregroundStyle(AppTheme.muted)
            }
        }
        .foregroundStyle(.white)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("升变 PAWN")
    }
}

struct AppPrimaryButtonLabel: View {
    let title: String
    let symbol: String

    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.headline)
            Spacer()
            Image(systemName: symbol)
                .font(.subheadline.weight(.bold))
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, minHeight: 54)
        .background(Color.white, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
    }
}

struct ProjectSummaryCard: View {
    let project: CreatorProject
    var showsAction = true
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

                if showsAction, project.stage != .settled {
                    Button(project.stage.actionTitle, action: action)
                        .buttonStyle(.bordered)
                        .tint(.white)
                        .font(.caption.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                } else if !showsAction {
                    HStack(spacing: 6) {
                        Spacer()
                        Text("查看项目")
                        Image(systemName: "chevron.right")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                }
            }
        }
    }
}