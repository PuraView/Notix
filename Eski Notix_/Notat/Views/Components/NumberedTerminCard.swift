
import SwiftUI

struct NumberedTerminCard: View {
    var index: Int
    var item: TerminItem

    var statusColor: Color {
        if item.isCompleted { return .statusComplete }
        if Date().isTodayLocal && Calendar.current.isDateInToday(item.dateTime) { return .statusToday }
        if item.dateTime < Date() { return .statusPast }
        return .statusFuture
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(statusColor, lineWidth: 3)
                    .frame(width: 36, height: 36)
                Text("\(index)")
                    .font(.system(size: 15, weight: .medium))
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.textPrimary)
                Text(item.dateTime.formattedShort())
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.textSecondary)
                if let note = item.note, !note.isEmpty {
                    Text(note)
                        .font(.system(size: 14))
                        .foregroundColor(.textTertiary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .padding(12)
        .background(item.isCompleted ? Color.statusComplete.opacity(0.15) : (item.dateTime < Date() && !Calendar.current.isDateInToday(item.dateTime) ? Color.statusPast.opacity(0.15) : Color.bgCard))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(item.title), \(item.dateTime.formattedShort())"))
    }
}
