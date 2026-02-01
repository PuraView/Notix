
import SwiftUI

enum MainTab: Int { case termin = 0, notiz = 1 }

struct CustomSegmentedControl: View {
    @Binding var selection: MainTab

    var body: some View {
        HStack(spacing: 8) {
            segment(titleKey: "termin", tab: .termin)
            segment(titleKey: "notiz", tab: .notiz)
        }
        .padding(8)
        .background(Color.segmentInactive)
        .clipShape(Capsule())
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func segment(titleKey: String, tab: MainTab) -> some View {
        Button {
            selection = tab
            HapticsService.shared.selection()
        } label: {
            Text(LocalizedStringKey(titleKey))
                .font(.system(size: 15, weight: selection == tab ? .medium : .regular))
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(selection == tab ? Color.segmentActive : Color.clear)
                .clipShape(Capsule())
        }
        .frame(height: 44)
        .accessibilityLabel(Text(LocalizedStringKey(titleKey)))
    }
}
