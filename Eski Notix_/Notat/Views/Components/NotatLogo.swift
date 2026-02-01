
import SwiftUI

struct NotatLogo: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.notatGradient)
                .frame(width: 36, height: 36)
            Image(systemName: "calendar")
                .foregroundColor(.white)
        }
        .accessibilityLabel(Text("app_name"))
    }
}
