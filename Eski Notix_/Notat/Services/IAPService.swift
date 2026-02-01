
import Foundation
import StoreKit

@MainActor
final class IAPService: ObservableObject {
    static let shared = IAPService()
    private init() {}

    @Published var isProUnlocked: Bool = false
    @Published var product: Product?

    func load() async {
        do {
            let products = try await Product.products(for: ["notat_pro"])
            product = products.first
            await refreshEntitlements()
        } catch {
            product = nil
        }
    }

    func refreshEntitlements() async {
        for await result in Transaction.currentEntitlements { // StoreKit 2 stream
            if case .verified(let transaction) = result, transaction.productID == "notat_pro" {
                isProUnlocked = true
                return
            }
        }
        isProUnlocked = false
    }

    func purchase() async -> Bool {
        do {
            guard let product = product else { return false }
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    isProUnlocked = true
                    await transaction.finish()
                    return true
                } else { return false }
            default:
                return false
            }
        } catch { return false }
    }

    func restore() async -> Bool {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            return isProUnlocked
        } catch { return false }
    }
}
