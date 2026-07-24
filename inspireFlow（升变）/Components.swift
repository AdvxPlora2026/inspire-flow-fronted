import SwiftUI

enum ShengbianMetrics {
    static let pageMargin: CGFloat = 20
    static let cardRadius: CGFloat = 12
    static let controlRadius: CGFloat = 12
    static let cardPadding: CGFloat = 16
    static let minimumControlHeight: CGFloat = 52
}

struct ShengbianBackground<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            ShengbianColors.canvas
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    ShengbianColors.glassHighlight.opacity(0.2),
                    .clear,
                    Color.black.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .accessibilityHidden(true)

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

                context.stroke(path, with: .color(ShengbianColors.grid), lineWidth: 0.5)
            }
            .ignoresSafeArea()
            .accessibilityHidden(true)

            content
        }
    }
}

struct ShengbianGlassCard<Content: View>: View {
    enum Emphasis {
        case standard
        case prominent
    }

    let emphasis: Emphasis
    @ViewBuilder let content: Content

    init(
        emphasis: Emphasis = .standard,
        @ViewBuilder content: () -> Content
    ) {
        self.emphasis = emphasis
        self.content = content()
    }

    var body: some View {
        content
            .padding(ShengbianMetrics.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(material, in: shape)
            .background(tint, in: shape)
            .overlay {
                shape
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                ShengbianColors.glassHighlight,
                                ShengbianColors.glassBorder
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.75
                    )
            }
            .shadow(color: Color.black.opacity(0.12), radius: 16, y: 8)
    }

    private var material: Material {
        emphasis == .prominent ? .regularMaterial : .thinMaterial
    }

    private var tint: Color {
        emphasis == .prominent
            ? ShengbianColors.glassTintStrong
            : ShengbianColors.glassTint
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: ShengbianMetrics.cardRadius,
            style: .continuous
        )
    }
}

struct ShengbianPrimaryButton: View {
    let title: LocalizedStringKey
    let symbol: String
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title)
                    .font(ShengbianTypography.headline)

                Spacer(minLength: 12)

                Image(systemName: symbol)
                    .font(.system(.subheadline, design: .default, weight: .bold))
                    .contentTransition(.symbolEffect(.replace))
            }
            .foregroundStyle(ShengbianColors.inverseText)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .frame(minHeight: ShengbianMetrics.minimumControlHeight)
            .background(
                ShengbianColors.primaryAction,
                in: RoundedRectangle(
                    cornerRadius: ShengbianMetrics.controlRadius,
                    style: .continuous
                )
            )
        }
        .buttonStyle(ShengbianPressStyle(reduceMotion: reduceMotion))
    }
}

struct ShengbianIconButton: View {
    let symbol: String
    let accessibilityLabel: LocalizedStringKey
    var isProminent = false
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(.body, design: .default, weight: .semibold))
                .foregroundStyle(ShengbianColors.primaryText)
                .frame(width: 44, height: 44)
                .background(.thinMaterial, in: shape)
                .background(
                    isProminent
                        ? ShengbianColors.glassTintStrong
                        : ShengbianColors.glassTint,
                    in: shape
                )
                .overlay {
                    shape.strokeBorder(ShengbianColors.glassBorder)
                }
        }
        .buttonStyle(ShengbianPressStyle(reduceMotion: reduceMotion))
        .accessibilityLabel(accessibilityLabel)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: ShengbianMetrics.controlRadius,
            style: .continuous
        )
    }
}

struct ShengbianStatusLabel: View {
    enum State {
        case neutral
        case listening
        case success
        case warning

        var color: Color {
            switch self {
            case .neutral: ShengbianColors.secondaryText
            case .listening: ShengbianColors.listening
            case .success: ShengbianColors.success
            case .warning: ShengbianColors.warning
            }
        }
    }

    let title: LocalizedStringKey
    let symbol: String
    let state: State

    var body: some View {
        Label(title, systemImage: symbol)
            .font(ShengbianTypography.caption)
            .foregroundStyle(state.color)
            .padding(.horizontal, 10)
            .frame(minHeight: 30)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(state.color.opacity(0.32), lineWidth: 0.75)
            }
            .accessibilityElement(children: .combine)
    }
}

struct ShengbianSectionHeader: View {
    let title: LocalizedStringKey
    var detail: LocalizedStringKey?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(title)
                .font(ShengbianTypography.headline)
                .foregroundStyle(ShengbianColors.primaryText)

            Spacer(minLength: 8)

            if let detail {
                Text(detail)
                    .font(ShengbianTypography.caption)
                    .foregroundStyle(ShengbianColors.secondaryText)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

struct ShengbianPressStyle: ButtonStyle {
    let reduceMotion: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(reduceMotion || !configuration.isPressed ? 1 : 0.975)
            .opacity(configuration.isPressed ? 0.78 : 1)
            .animation(
                reduceMotion ? nil : .easeOut(duration: 0.12),
                value: configuration.isPressed
            )
    }
}

extension View {
    /// Applies the shared press feedback (scale + opacity) used by the
    /// Shengbian primary/icon buttons to any custom `Button`.
    func shengbianPressable(reduceMotion: Bool) -> some View {
        buttonStyle(ShengbianPressStyle(reduceMotion: reduceMotion))
    }
}