import Foundation
import StoreKit
import Combine

@MainActor
final class IAPService: ObservableObject {
    static let shared = IAPService()
    private init() {}

    @Published var isProUnlocked: Bool = false
    @Published var product: Product?

    func load() async {
        do {
            print("[IAP] load start")
            let products = try await Product.products(for: ["notat_pro"])
            product = products.first
            print("[IAP] products fetched:", products.map(\.id))
            await refreshEntitlements()
        } catch {
            print("[IAP] load error:", error.localizedDescription)
            product = nil
        }
    }

    func refreshEntitlements() async {
        print("[IAP] refreshEntitlements")
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let t):
                print("[IAP] entitlement verified:", t.productID)
                if t.productID == "notat_pro" {
                    isProUnlocked = true
                    return
                }
            case .unverified(let t, let e):
                print("[IAP] entitlement unverified:", t.productID, e.localizedDescription)
            }
        }
        isProUnlocked = false
    }

    func purchase() async -> Bool {
        print("[IAP] purchase tapped")
        do {
            guard let product = product else {
                print("[IAP] purchase aborted: product is nil")
                return false
            }
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                print("[IAP] purchase success (needs verification)")
                if case .verified(let transaction) = verification {
                    print("[IAP] transaction verified:", transaction.productID)
                    isProUnlocked = true
                    await transaction.finish()
                    return true
                } else {
                    print("[IAP] transaction unverified")
                    return false
                }
            case .userCancelled:
                print("[IAP] user cancelled")
                return false
            case .pending:
                print("[IAP] purchase pending")
                return false
            @unknown default:
                print("[IAP] purchase unknown case")
                return false
            }
        } catch {
            print("[IAP] purchase error:", error.localizedDescription)
            return false
        }
    }

    func restore() async -> Bool {
        print("[IAP] restore tapped")
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            print("[IAP] restore result isPro:", isProUnlocked)
            return isProUnlocked
        } catch {
            print("[IAP] restore error:", error.localizedDescription)
            return false
        }
    }
}

