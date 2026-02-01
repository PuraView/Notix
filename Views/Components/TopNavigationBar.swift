import SwiftUI

struct TopNavigationBar: View {
    var onSettings: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                NotatLogo(size: 42, cornerRadius: 10, addBorder: true)
                Text("app_name")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.textPrimary)
                Spacer()
                Button(action: onSettings) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .foregroundColor(colorScheme == .dark ? .white : .textPrimary)
                        .symbolRenderingMode(.monochrome)
                }
                .accessibilityLabel(Text("einstellungen"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)

            Rectangle()
                .fill(Color(UIColor.systemGray4).opacity(0.6))
                .frame(height: 0.5)
                .frame(maxWidth: .infinity)
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea(edges: .top))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}
