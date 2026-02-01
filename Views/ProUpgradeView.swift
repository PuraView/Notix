
import SwiftUI

struct ProUpgradeView: View {
    @EnvironmentObject var purchaseVM: PurchaseViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("pro_upgrade").font(.title3)
            Text("unlock_unlimited")
            Text("price_label").foregroundColor(.secondary)
            HStack(spacing: 12) {
                Button("upgrade") { Task { await purchaseVM.purchase() } }
                    .buttonStyle(.borderedProminent)
                Button("restore_purchase") { Task { await purchaseVM.restore() } }
                    .buttonStyle(.bordered)
            }
            Spacer()
        }
        .padding(24)
        .navigationTitle(Text("pro_upgrade"))
    }
}
