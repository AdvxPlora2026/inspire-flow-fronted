import SwiftUI
import UIKit

/// Central haptic feedback layer. Haptics are independent from
/// `accessibilityReduceMotion`; the system honors the user's global haptics
/// setting automatically, so callers do not need to gate these.
@MainActor
enum Haptics {
    enum Impact {
        case light
        case medium
        case rigid
        case soft

        fileprivate var style: UIImpactFeedbackGenerator.FeedbackStyle {
            switch self {
            case .light: .light
            case .medium: .medium
            case .rigid: .rigid
            case .soft: .soft
            }
        }
    }

    private static let selectionGenerator = UISelectionFeedbackGenerator()
    private static let notificationGenerator = UINotificationFeedbackGenerator()

    static func impact(_ impact: Impact, intensity: CGFloat = 1) {
        let generator = UIImpactFeedbackGenerator(style: impact.style)
        generator.prepare()
        generator.impactOccurred(intensity: intensity)
    }

    static func selection() {
        selectionGenerator.prepare()
        selectionGenerator.selectionChanged()
    }

    static func success() {
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(.success)
    }

    static func warning() {
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(.warning)
    }

    static func error() {
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(.error)
    }
}

/// Shared motion tokens so animation feel stays consistent across the app.
/// Exposed on `Animation` so leading-dot syntax works inside
/// `ShengbianMotion.maybe(.snappySpring, reduceMotion)` where the expected type
/// is `Animation`.
extension Animation {
    static let standardSpring = Animation.spring(response: 0.34, dampingFraction: 0.82)
    static let snappySpring = Animation.spring(response: 0.28, dampingFraction: 0.86)
    static let gentle = Animation.easeOut(duration: 0.2)
    static let pulse = Animation.easeInOut(duration: 1.6)
}

enum ShengbianMotion {
    static let standardSpring = Animation.standardSpring
    static let snappySpring = Animation.snappySpring
    static let gentle = Animation.gentle
    static let pulse = Animation.pulse

    /// Returns the animation, or `nil` when Reduce Motion is on, so callers can
    /// write `withAnimation(ShengbianMotion.maybe(.standardSpring, reduceMotion))`.
    static func maybe(_ animation: Animation, _ reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : animation
    }
}
