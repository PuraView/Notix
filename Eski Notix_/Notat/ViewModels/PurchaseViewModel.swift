
import Foundation
import StoreKit

@MainActor
final class PurchaseViewModel: ObservableObject {
    @Published var isPro: Bool = false
    @Published var product: Product?

    func onAppear() {
        Task { await load() }
    }

    private func load() async {
        await IAPService.shared.load()
        await MainActor.run { [weak self] in
            self?.isPro = IAPService.shared.isProUnlocked
            self?.product = IAPService.shared.product
        }
    }

    func purchase() async {
        let ok = await IAPService.shared.purchase()
        await MainActor.run { [weak self] in self?.isPro = ok || IAPService.shared.isProUnlocked }
    }

    func restore() async {
        let ok = await IAPService.shared.restore()
        await MainActor.run { [weak self] in self?.isPro = ok || IAPService.shared.isProUnlocked }
    }
}
