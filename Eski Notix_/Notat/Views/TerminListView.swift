
import SwiftUI

struct TerminListView: View {
    @EnvironmentObject var terminVM: TerminViewModel
    @EnvironmentObject var purchaseVM: PurchaseViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if terminVM.items.isEmpty {
                    // Ultra minimal empty state: just space
                    Spacer(minLength: 80)
                } else {
                    ForEach(Array(terminVM.items.enumerated()), id: \.element.id) { index, item in
                        NumberedTerminCard(index: index+1, item: item)
                            .contextMenu { Button("edit", action: { terminVM.editingItem = item }) }
                            .onTapGesture { terminVM.editingItem = item }
                            .swipeActions(edge: .leading) {
                                Button("complete") { terminVM.markComplete(item) }.tint(.green)
                                Button(role: .destructive) { terminVM.delete(item) } label: { Text("delete") }
                            }
                            .swipeActions(edge: .trailing) {
                                Button("edit") { terminVM.editingItem = item }
                            }
                    }
                }
            }
            .padding(16)
        }
        .sheet(item: $terminVM.editingItem) { item in
            AddTerminSheet(editing: item)
        }
        .alert("limit_reached", isPresented: $terminVM.showUpgradeBanner) {
            Button("upgrade") { /* open settings or pro view via deep link? */ }
            Button("cancel", role: .cancel) { }
        }
    }
}
