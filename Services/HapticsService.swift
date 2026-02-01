import UIKit

@MainActor
final class HapticsService {
    static let shared = HapticsService()
    private init() {}

    private var isEnabled: Bool {
        if UserDefaults.standard.object(forKey: "hapticsEnabled") == nil { return true }
        return UserDefaults.standard.bool(forKey: "hapticsEnabled")
    }

    func success() { guard isEnabled else { return }; UINotificationFeedbackGenerator().notificationOccurred(.success) }
    func warning() { guard isEnabled else { return }; UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    func error() { guard isEnabled else { return }; UINotificationFeedbackGenerator().notificationOccurred(.error) }
    func selection() { guard isEnabled else { return }; UISelectionFeedbackGenerator().selectionChanged() }
    func light() { guard isEnabled else { return }; UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    func medium() { guard isEnabled else { return }; UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
}
