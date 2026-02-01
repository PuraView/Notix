import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

extension Color {
    init(hex: String) {
        let hexSan = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hexSan).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hexSan.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }

#if canImport(UIKit)
    private static func dynamic(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? dark : light
        })
    }
#endif

    // MARK: Logo & Primary
    static let notatBlue = Color(hex: "#4A90E2")
    static let notatMint = Color(hex: "#5FD4C4")
    static var notatGradient: LinearGradient {
        LinearGradient(colors: [notatBlue, notatMint], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    // MARK: Status
    static let statusFuture = Color(hex: "#6BA3D6")
    static let statusToday = Color(hex: "#FFB84D")
    static let statusPast = Color(hex: "#E8A5A5")
    static let statusComplete = Color(hex: "#85D6A5")

    // MARK: Backgrounds
#if canImport(UIKit)
    static let bgPrimary = Color(UIColor.systemBackground)
    static let bgSecondary = Color(UIColor.systemGray6).opacity(0.5)
    static let bgCard = Color(UIColor.systemGray6).opacity(0.3)
#else
    static let bgPrimary = Color.white
    static let bgSecondary = Color.gray.opacity(0.1)
    static let bgCard = Color.gray.opacity(0.08)
#endif

    // MARK: Segmented
    static let segmentActive = Color.notatMint
#if canImport(UIKit)
    static let segmentInactive = Color(UIColor.systemGray6)
#else
    static let segmentInactive = Color.gray.opacity(0.12)
#endif

    // MARK: Text
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color.secondary.opacity(0.6)

    // MARK: Pure Grayscale Dark Mode
#if canImport(UIKit)
    private static let dmBackground = UIColor(red: 0x0F/255.0, green: 0x0F/255.0, blue: 0x0F/255.0, alpha: 1.0)
    private static let dmCard       = UIColor(red: 0x1E/255.0, green: 0x1E/255.0, blue: 0x1E/255.0, alpha: 1.0)
    private static let dmStroke     = UIColor(red: 0x2A/255.0, green: 0x2A/255.0, blue: 0x2A/255.0, alpha: 1.0)

    private static let dmTextPrimary   = UIColor(red: 0xF2/255.0, green: 0xF2/255.0, blue: 0xF2/255.0, alpha: 1.0)
    private static let dmTextSecondary = UIColor(red: 0xB3/255.0, green: 0xB3/255.0, blue: 0xB3/255.0, alpha: 1.0)

    private static let dmControlTrack  = UIColor(red: 0x1A/255.0, green: 0x1A/255.0, blue: 0x1A/255.0, alpha: 1.0)
    private static let dmControlFill   = UIColor(red: 0x33/255.0, green: 0x33/255.0, blue: 0x33/255.0, alpha: 1.0)
    private static let dmControlText   = UIColor(red: 0xE6/255.0, green: 0xE6/255.0, blue: 0xE6/255.0, alpha: 1.0)

    static let darkBackground = dynamic(light: UIColor.systemBackground, dark: dmBackground)
    static let darkCard       = dynamic(light: UIColor.systemGray6.withAlphaComponent(0.3), dark: dmCard)
    static let darkStroke     = dynamic(light: .clear, dark: dmStroke)

    static let darkTextPrimary   = dynamic(light: UIColor.label, dark: dmTextPrimary)
    static let darkTextSecondary = dynamic(light: UIColor.secondaryLabel, dark: dmTextSecondary)

    static let darkControlTrack  = dynamic(light: UIColor.systemGray6, dark: dmControlTrack)
    static let darkControlFill   = dynamic(light: UIColor(Color.notatMint), dark: dmControlFill)
    static let darkControlText   = dynamic(light: .white, dark: dmControlText)
#else
    static let darkBackground = Color.black
    static let darkCard       = Color.gray.opacity(0.2)
    static let darkStroke     = Color.clear

    static let darkTextPrimary   = Color.primary
    static let darkTextSecondary = Color.secondary

    static let darkControlTrack  = Color.gray.opacity(0.2)
    static let darkControlFill   = Color.notatMint.opacity(0.8)
    static let darkControlText   = Color.white
#endif

    // MARK: Unified Card Background
#if canImport(UIKit)
    private static let softTurquoiseLight = UIColor(red: 0x4F/255.0, green: 0xD1/255.0, blue: 0xC5/255.0, alpha: 0.15)
    static func cardBackground(at _: Int) -> Color {
        dynamic(light: softTurquoiseLight, dark: dmCard)
    }
#else
    static func cardBackground(at _: Int) -> Color {
        Color.notatMint.opacity(0.15)
    }
#endif

    // “New” button
#if canImport(UIKit)
    static let primaryButtonBg   = dynamic(light: UIColor(red: 0x5F/255.0, green: 0xD4/255.0, blue: 0xC4/255.0, alpha: 1.0), dark: dmControlFill)
    static let primaryButtonText = dynamic(light: .white, dark: dmControlText)
#else
    static let primaryButtonBg   = Color.notatMint
    static let primaryButtonText = Color.white
#endif

    // Segmented control
    static let segmentedTrack        = darkControlTrack
    static let segmentedFill         = darkControlFill
    static let segmentedTextSelected = darkControlText
#if canImport(UIKit)
    static let segmentedTextIdle     = dynamic(light: UIColor.label, dark: dmTextSecondary)
#else
    static let segmentedTextIdle     = Color.secondary
#endif

    // MARK: - Screen gradient for create/edit and form tokens
    static var screenGradientTeal: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "#d0f2ef"), Color(hex: "#e8f9f7"), Color(hex: "#f5fcfb")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // Merkezi form tokenları: Light (kırık beyaz/yeşilimsi bej), Dark (mevcut opaklıklar)
#if canImport(UIKit)
    static let formBackground: Color = dynamic(
        light: UIColor(Color(hex: "#E9F3F0")),     // yeni açık ton
        dark: UIColor.white.withAlphaComponent(0.08)
    )
    static let formBorder: Color = dynamic(
        light: UIColor(Color(hex: "#C9E0DB")),     // yeni sınır tonu
        dark: UIColor.white.withAlphaComponent(0.15)
    )
    static let formShadow: Color = dynamic(
        light: UIColor.black.withAlphaComponent(0.10), // gölge %10
        dark: UIColor.black.withAlphaComponent(0.30)
    )
#else
    static let formBackground: Color = Color(hex: "#E9F3F0")
    static let formBorder: Color = Color(hex: "#C9E0DB")
    static let formShadow: Color = Color.black.opacity(0.10)
#endif
}
