import SwiftUI
import UIKit

/// Design "L3 · Radar Day" (light) + "Phosphor" (dark). See design/index.html.
/// Rule: amber is only a fill (selected day, highlights) with ink text on top, never a text colour on light backgrounds.
enum Theme {
    static let background = Color(light: 0xEAEEF4, dark: 0x0C1018)
    static let text       = Color(light: 0x16203A, dark: 0xF3EEE3)
    /// Icons, rings, active tab in light mode.
    static let ink        = Color(light: 0x24324F, dark: 0xF3EEE3)
    static let amber      = Color(hex: 0xFFB23E)
    /// Text that sits on an amber fill, in both modes.
    static let onAmber    = Color(hex: 0x16203A)
    static let urgent     = Color(light: 0xCC3A22, dark: 0xFF6B4F)
    /// Selected tab: ink on light glass, amber on dark glass.
    static let activeTab  = Color(light: 0x24324F, dark: 0xFFB23E)
}

extension Color {
    init(hex: UInt32) {
        self.init(uiColor: UIColor(hex: hex))
    }

    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light) })
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: 1)
    }
}

extension View {
    /// Frosted Liquid Glass card used for every surface in the app.
    func glassCard(cornerRadius: CGFloat = 18, padding: CGFloat = 14) -> some View {
        self.padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
    }
}
