import SwiftUI

struct NotatLogo: View {
    var size: CGFloat = 36
    var cornerRadius: CGFloat = 8      // iOS app icon hissi için 7–10 iyi durur
    var addBorder: Bool = true         // İstersen ince bir stroke

    var body: some View {
        Image("AppLogo")
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                if addBorder {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.black.opacity(0.06), lineWidth: 0.5) // çok hafif bir kenarlık
                }
            }
            .accessibilityLabel(Text("app_name"))
    }
}
