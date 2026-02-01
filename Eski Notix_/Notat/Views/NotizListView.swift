
import SwiftUI

struct NotizListView: View {
    @EnvironmentObject var notesVM: NotesViewModel

    var body: some View {
        List {
            ForEach(notesVM.items) { item in
                MinimalNoteCard(item: item)
                    .onTapGesture { notesVM.editingItem = item }
                    .swipeActions(edge: .leading) {
                        Button(role: .destructive) { notesVM.delete(item) } label: { Text("delete") }
                    }
            }
            .onMove(perform: notesVM.move)
        }
        .listStyle(.plain)
        .sheet(item: $notesVM.editingItem) { item in
            AddNoteSheet(editing: item)
        }
    }
}
