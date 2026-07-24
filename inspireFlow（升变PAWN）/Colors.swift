import SwiftUI

enum ShengbianColors {
    static let canvas = Color(
        light: UIColor(white: 0.95, alpha: 1),
        dark: UIColor(red: 0.018, green: 0.019, blue: 0.022, alpha: 1)
    )

    static let canvasElevated = Color(
        light: UIColor(white: 1, alpha: 0.82),
        dark: UIColor(white: 0.12, alpha: 0.78)
    )

    static let glassTint = Color(
        light: UIColor(white: 1, alpha: 0.58),
        dark: UIColor(white: 1, alpha: 0.075)
    )

    static let glassTintStrong = Color(
        light: UIColor(white: 1, alpha: 0.82),
        dark: UIColor(white: 1, alpha: 0.13)
    )

    static let glassBorder = Color(
        light: UIColor(white: 0, alpha: 0.09),
        dark: UIColor(white: 1, alpha: 0.15)
    )

    static let glassHighlight = Color(
        light: UIColor(white: 1, alpha: 0.76),
        dark: UIColor(white: 1, alpha: 0.22)
    )

    static let primaryText = Color.primary
    static let secondaryText = Color.secondary

    static let tertiaryText = Color(
        light: UIColor(white: 0, alpha: 0.42),
        dark: UIColor(white: 1, alpha: 0.38)
    )

    static let inverseText = Color(
        light: UIColor.white,
        dark: UIColor.black
    )

    static let primaryAction = Color(
        light: UIColor.black,
        dark: UIColor.white
    )

    static let listening = Color(
        light: UIColor.black,
        dark: UIColor.white
    )

    static let success = Color(
        light: UIColor(white: 0.12, alpha: 1),
        dark: UIColor(white: 0.92, alpha: 1)
    )

    static let warning = Color(
        light: UIColor(white: 0.3, alpha: 1),
        dark: UIColor(white: 0.7, alpha: 1)
    )

    static let grid = Color(
        light: UIColor(white: 0, alpha: 0.035),
        dark: UIColor(white: 1, alpha: 0.022)
    )
}

private extension Color {
    init(light: UIColor, dark: UIColor) {
        self.init(
            UIColor { traits in
                traits.userInterfaceStyle == .dark ? dark : light
            }
        )
    }
}
