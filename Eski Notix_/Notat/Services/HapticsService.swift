
import UIKit

@MainActor
final class HapticsService {
    static let shared = HapticsService()
    private init() {}

    func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    func warning() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    func error() { UINotificationFeedbackGenerator().notificationOccurred(.error) }
    func selection() { UISelectionFeedbackGenerator().selectionChanged() }
    func light() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    func medium() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
}
