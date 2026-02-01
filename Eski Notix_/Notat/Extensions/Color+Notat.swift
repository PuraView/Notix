
import SwiftUI

extension Color {
    init(hex: String) {
        var hexSan = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hexSan).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hexSan.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }

    // Logo & Primary
    static let notatBlue = Color(hex: "#4A90E2")
    static let notatMint = Color(hex: "#5FD4C4")

    static var notatGradient: LinearGradient {
        LinearGradient(colors: [notatBlue, notatMint], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    // Status Colors (PASTEL - NO HARSH REDS!)
    static let statusFuture = Color(hex: "#6BA3D6") // Soft blue
    static let statusToday = Color(hex: "#FFB84D") // Soft orange
    static let statusPast = Color(hex: "#E8A5A5") // Soft pink (not red!)
    static let statusComplete = Color(hex: "#85D6A5") // Soft green

    // Backgrounds
    static let bgPrimary = Color(.systemBackground)
    static let bgSecondary = Color(.systemGray6).opacity(0.5)
    static let bgCard = Color(.systemGray6).opacity(0.3)

    // Segmented Control
    static let segmentActive = Color(hex: "#E5F3F5") // Very light mint
    static let segmentInactive = Color(.systemGray6)

    // Text
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color.secondary.opacity(0.6)
}
