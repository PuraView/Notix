import SwiftUI

// Çizgisiz, modern kart (başlık/tarih hiyerarşisi, yumuşak arka plan, rounded + shadow)
struct TerminCard: View {
    var item: TerminItem
    @Environment(\.colorScheme) private var colorScheme

    private let corner: CGFloat = 16

    // MARK: - Dark mode teal options
    // Option 1 (Subtle - Recommended)
    private var darkTealBackground: Color { Color(hex: "#4fd1c5").opacity(0.15) } // rgba(79,209,197,0.15)
    // Option 2 (More visible)
    private var darkTealBackgroundStronger: Color { Color(hex: "#4fd1c5").opacity(0.25) } // rgba(79,209,197,0.25)
    // Option 3 (Gradient 90deg)
    private var darkTealGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "#4fd1c5").opacity(0.20), Color(hex: "#38b2ac").opacity(0.15)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // Choose which option to use
    private var darkBackgroundView: some View {
        // Change between options here:
        // 1) Solid subtle
        AnyView(darkTealBackground)
        // 2) Stronger
        // AnyView(darkTealBackgroundStronger)
        // 3) Gradient
        // AnyView(darkTealGradient)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? .white : .darkTextPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(item.dateTime.formattedShort())
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .darkTextSecondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            Spacer()
        }
        .padding(16) // prompt: padding 16px
        .background(
            Group {
                if colorScheme == .dark {
                    darkBackgroundView // teal semi-transparent
                } else {
                    Color.cardBackground(at: item.id.hashValue) // existing pastel in light mode
                }
            }
        )
        .cornerRadius(corner) // prompt: 16px radius
        .overlay(
            // No border in dark mode (prompt: no left border; we remove full stroke)
            Group {
                if colorScheme == .dark {
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .stroke(Color.clear, lineWidth: 0)
                } else {
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .stroke(Color.darkStroke, lineWidth: 1)
                }
            }
        )
        .shadow(
            color: colorScheme == .dark ? Color(hex: "#4fd1c5").opacity(0.15) : Color.black.opacity(0.08),
            radius: 8, x: 0, y: 2
        ) // prompt: rgba(79,209,197,0.15)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(item.title), \(item.dateTime.formattedShort())"))
        .padding(.bottom, 12) // prompt: margin-bottom 12px between cards (liste layout’ında spacing de var)
    }
}
