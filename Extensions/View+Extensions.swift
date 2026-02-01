
import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
            .padding(12)
            .background(Color.bgCard)
            .cornerRadius(12)
    }

    // İçeriğin doğal yüksekliğini koruyarak (minHeight yok),
    // tam genişlikte kart arka planı uygular.
    func flexibleCard(background: Color,
                      cornerRadius: CGFloat = 12,
                      padding: CGFloat = 12) -> some View {
        modifier(FlexibleCardModifier(background: background,
                                      cornerRadius: cornerRadius,
                                      padding: padding))
    }
}

private struct FlexibleCardModifier: ViewModifier {
    let background: Color
    let cornerRadius: CGFloat
    let padding: CGFloat

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading) // yatayda tam genişlik
            .padding(padding)                                // iç boşluk
            .background(background)                          // arka planı kapsayıcıya uygula
            .cornerRadius(cornerRadius)                      // köşe yuvarla
            .frame(maxWidth: .infinity, alignment: .leading) // dışta da tam genişlik
    }
}
