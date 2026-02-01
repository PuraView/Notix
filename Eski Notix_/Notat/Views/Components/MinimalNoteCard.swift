
import SwiftUI

struct MinimalNoteCard: View {
    var item: NoteItem

    var body: some View {
        Text(item.text.split(separator: "
").first.map(String.init) ?? item.text)
            .font(.system(size: 15))
            .foregroundColor(.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color.bgCard)
            .cornerRadius(12)
            .accessibilityLabel(Text(item.text))
    }
}
