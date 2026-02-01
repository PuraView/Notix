
import SwiftUI

struct AddNoteSheet: View {
    @EnvironmentObject var notesVM: NotesViewModel
    var editing: NoteItem? = nil
    @State private var text: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("notiz", text: $text, axis: .vertical)
                        .lineLimit(4...10)
                }
            }
            .navigationTitle(Text(editing == nil ? "create_new" : "edit"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("close") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        if let e = editing { notesVM.update(item: e, text: text) } else { notesVM.create(text: text) }
                        dismiss()
                    }
                }
            }
            .onAppear { if let e = editing { text = e.text } }
        }
    }
}
