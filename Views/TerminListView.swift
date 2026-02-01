import SwiftUI

struct TerminListView: View {
    @EnvironmentObject var terminVM: TerminViewModel
    @EnvironmentObject var purchaseVM: PurchaseViewModel

    // Silme onayı için state
    @State private var itemPendingDelete: TerminItem? = nil
    @State private var showDeleteAlert: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 1) { // 2 → 1 (daha kompakt)
                if terminVM.items.isEmpty {
                    Spacer(minLength: 80)
                } else {
                    ForEach(terminVM.items) { item in
                        TerminRow(
                            item: item,
                            requestDelete: { toDelete in
                                itemPendingDelete = toDelete
                                showDeleteAlert = true
                            }
                        )
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 120) // FAB ile çakışmayı önlemek için
        }
        .sheet(item: $terminVM.editingItem) { item in
            AddTerminSheet(editing: item)
        }
        .alert("limit_reached", isPresented: $terminVM.showUpgradeBanner) {
            Button("upgrade") { /* open settings or pro view via deep link? */ }
            Button("cancel", role: .cancel) { }
        }
        // Silme onayı alert'i (yalnızca başlık + butonlar)
        .alert(
            Text(LocalizedStringKey("confirm_delete_title")),
            isPresented: $showDeleteAlert,
            presenting: itemPendingDelete
        ) { item in
            Button(role: .destructive) {
                terminVM.delete(item: item)
                itemPendingDelete = nil
            } label: {
                Text(LocalizedStringKey("delete_confirm"))
            }
            Button(role: .cancel) {
                itemPendingDelete = nil
            } label: {
                Text(LocalizedStringKey("cancel"))
            }
        }
    }
}

private struct TerminRow: View {
    let item: TerminItem
    @EnvironmentObject var terminVM: TerminViewModel

    // Dışarıdan silme isteği tetiklemek için closure
    var requestDelete: (TerminItem) -> Void

    var body: some View {
        TerminCard(item: item)
            .contentShape(Rectangle())
            .contextMenu {
                Button("edit", action: { terminVM.editingItem = item })
                Button(role: .destructive) {
                    requestDelete(item)
                } label: { Text("delete") }
            }
            .onTapGesture { terminVM.editingItem = item }
            .swipeActions(edge: .leading) {
                Button("complete") { terminVM.markComplete(item) }.tint(.green)
            }
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    requestDelete(item)
                } label: { Text("delete") }
                Button("edit") { terminVM.editingItem = item }
            }
    }
}
