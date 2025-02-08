import SwiftUI

extension Color {
    static let neuBackground = Color(hex: "E0D6D1")  // Warm beige background
    static let neuForeground = Color.white.opacity(0.95)  // Slightly off-white for cards
    static let neuPrimary = Color(hex: "E5C1B8")  // Rose gold/pink
    static let neuSecondary = Color(hex: "9E8B85")  // Darker beige/brown
    static let neuText = Color(hex: "463E3F")  // Dark gray text
    static let neuShadowDark = Color.black.opacity(0.15)
    static let neuShadowLight = Color.white.opacity(0.9)
}

// Helper for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3:  // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
