
import SwiftUI

struct AddButton: View {
    var titleKey: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "plus")
                Text(LocalizedStringKey(titleKey))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.notatMint)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        }
        .accessibilityLabel(Text(LocalizedStringKey(titleKey)))
    }
}
