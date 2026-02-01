
import SwiftUI

struct TopNavigationBar: View {
    var onSettings: () -> Void

    var body: some View {
        HStack {
            NotatLogo()
            Text("app_name")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.textPrimary)
            Spacer()
            Button(action: onSettings) {
                Image(systemName: "person.crop.circle")
                    .font(.title3)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(Text("einstellungen"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
