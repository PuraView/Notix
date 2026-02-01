import SwiftUI

struct NotizListView: View {
    @EnvironmentObject var notesVM: NotesViewModel

    // Silme onayı için state
    @State private var notePendingDelete: NoteItem? = nil
    @State private var showDeleteAlert: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if notesVM.items.isEmpty {
                    Spacer(minLength: 80)
                } else {
                    ForEach(Array(notesVM.items.enumerated()), id: \.element.id) { index, item in
                        MinimalNoteCard(item: item, index: index)
                            .contextMenu {
                                Button("edit") { notesVM.editingItem = item }
                                Button(role: .destructive) {
                                    notePendingDelete = item
                                    showDeleteAlert = true
                                } label: { Text("delete") }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    notePendingDelete = item
                                    showDeleteAlert = true
                                } label: { Text("delete") }
                            }
                            .swipeActions(edge: .leading) {
                                Button("edit") { notesVM.editingItem = item }
                                    .tint(.blue)
                            }
                            .onTapGesture { notesVM.editingItem = item }
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 120)
        }
        .sheet(item: $notesVM.editingItem) { item in
            AddNoteSheet(editing: item)
        }
        // Silme onayı alert'i (yalnızca başlık + butonlar)
        .alert(
            Text(LocalizedStringKey("confirm_delete_title")),
            isPresented: $showDeleteAlert,
            presenting: notePendingDelete
        ) { note in
            Button(role: .destructive) {
                notesVM.delete(item: note)
                notePendingDelete = nil
            } label: {
                Text(LocalizedStringKey("delete_confirm"))
            }
            Button(role: .cancel) {
                notePendingDelete = nil
            } label: {
                Text(LocalizedStringKey("cancel"))
            }
        }
    }
}
