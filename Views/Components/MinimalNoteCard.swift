import SwiftUI

struct MinimalNoteCard: View {
    var item: NoteItem
    var index: Int
    @Environment(\.colorScheme) private var colorScheme

    // Appointment kartlarıyla uyumlu: min 6 satır, max 8 satır göster
    private let minVisibleLines: Int = 6
    private let maxVisibleLines: Int = 8

    // Dark mode teal background (Option 1: subtle 15%)
    private var darkTealBackground: Color { Color(hex: "#4fd1c5").opacity(0.15) } // rgba(79,209,197,0.15)
    private var darkTealShadow: Color { Color(hex: "#4fd1c5").opacity(0.15) }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.text.isEmpty ? " " : item.text)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(colorScheme == .dark ? .white : .darkTextPrimary) // dark: #fff
                .lineLimit(maxVisibleLines)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .frame(minHeight: estimatedMinHeightForLines(minVisibleLines), alignment: .topLeading)
        .background(
            colorScheme == .dark
            ? darkTealBackground
            : Color.cardBackground(at: index) // light: pastel
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    colorScheme == .dark ? Color.clear : Color.darkStroke,
                    lineWidth: colorScheme == .dark ? 0 : 1
                )
        )
        .shadow(
            color: colorScheme == .dark ? darkTealShadow : Color.black.opacity(0.08),
            radius: 8, x: 0, y: 2
        )
        .accessibilityLabel(Text(item.text))
    }

    private func estimatedMinHeightForLines(_ lines: Int) -> CGFloat {
        let lineHeight: CGFloat = 22
        let verticalPadding: CGFloat = 40 // .padding(20) üst+alt
        return CGFloat(lines) * lineHeight + verticalPadding
    }
}
