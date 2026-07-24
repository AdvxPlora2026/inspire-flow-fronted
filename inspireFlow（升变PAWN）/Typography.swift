import SwiftUI

enum ShengbianTypography {
    static let display = Font.system(.largeTitle, design: .default, weight: .bold)
    static let title = Font.system(.title, design: .default, weight: .bold)
    static let title2 = Font.system(.title2, design: .default, weight: .semibold)
    static let title3 = Font.system(.title3, design: .default, weight: .semibold)
    static let headline = Font.system(.headline, design: .default, weight: .semibold)
    static let body = Font.system(.body, design: .default, weight: .regular)
    static let bodyEmphasized = Font.system(.body, design: .default, weight: .semibold)
    static let callout = Font.system(.callout, design: .default, weight: .regular)
    static let subheadline = Font.system(.subheadline, design: .default, weight: .regular)
    static let caption = Font.system(.caption, design: .default, weight: .medium)
    static let label = Font.system(.caption2, design: .default, weight: .semibold)
    static let metric = Font.system(.body, design: .monospaced, weight: .semibold)
    static let technical = Font.system(.caption, design: .monospaced, weight: .medium)
}

struct ShengbianDisplayText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(ShengbianTypography.display)
            .foregroundStyle(ShengbianColors.primaryText)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }
}

struct ShengbianBodyText: ViewModifier {
    let secondary: Bool

    func body(content: Content) -> some View {
        content
            .font(ShengbianTypography.body)
            .foregroundStyle(
                secondary
                    ? ShengbianColors.secondaryText
                    : ShengbianColors.primaryText
            )
            .lineSpacing(3)
            .fixedSize(horizontal: false, vertical: true)
    }
}

extension View {
    func shengbianDisplayText() -> some View {
        modifier(ShengbianDisplayText())
    }

    func shengbianBodyText(secondary: Bool = false) -> some View {
        modifier(ShengbianBodyText(secondary: secondary))
    }
}