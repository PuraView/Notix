import Foundation
import Combine
import SwiftUI

final class TerminViewModel: ObservableObject {
    @Published var items: [TerminItem] = []
    @Published var editingItem: TerminItem?
    @Published var showUpgradeBanner: Bool = false
    @Published var showAddSheet: Bool = false
    @Published var notifyDayBefore: Bool = false
    @Published var notifyHourBefore: Bool = false

    private let persistence = PersistenceService()
    private let notification = NotificationService()
    private var saveTask: Task<Void, Never>? = nil

    private let freeLimit: Int = 10

    func load() {
        Task {
            let loaded = await persistence.loadTermins()
            await MainActor.run { [weak self] in
                self?.items = Self.sort(loaded)
            }
        }
    }

    static func sort(_ items: [TerminItem]) -> [TerminItem] {
        let now = Date()
        let incomplete = items.filter { !$0.isCompleted }
        let past = incomplete.filter { $0.dateTime < now }.sorted { $0.dateTime < $1.dateTime }
        let future = incomplete.filter { $0.dateTime >= now }.sorted { $0.dateTime < $1.dateTime }
        let completed = items.filter { $0.isCompleted }.sorted { $0.dateTime < $1.dateTime }
        return past + future + completed
    }

    @discardableResult
    func create(title: String, dateTime: Date, note: String?, isPro: Bool, reminder: Reminder? = nil) -> TerminItem? {
        if !isPro && items.count >= freeLimit {
            showUpgradeBanner = true
            HapticsService.shared.warning()
            return nil
        }
        var newItem = TerminItem(title: title, dateTime: dateTime, note: note)
        newItem.reminder = reminder
        items.append(newItem)
        items = Self.sort(items)
        scheduleNotificationsIfNeeded(for: newItem)
        saveDebounced()
        HapticsService.shared.success()
        return newItem
    }

    func update(item: TerminItem, title: String, dateTime: Date, note: String?, reminder: Reminder? = nil) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        var updated = item
        updated.title = title
        updated.dateTime = dateTime
        updated.note = note
        updated.reminder = reminder
        items[idx] = updated
        items = Self.sort(items)
        Task {
            await notification.cancelNotifications(for: item.id)
            await scheduleNotificationsIfNeeded(for: updated)
        }
        saveDebounced()
        HapticsService.shared.selection()
    }

    func delete(item: TerminItem) {
        items.removeAll { $0.id == item.id }
        Task { await notification.cancelNotifications(for: item.id) }
        saveDebounced()
        HapticsService.shared.medium()
    }

    func markComplete(_ item: TerminItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        var updated = item
        updated.isCompleted.toggle()
        items[idx] = updated
        items = Self.sort(items)
        Task {
            await notification.cancelNotifications(for: item.id)
            if !updated.isCompleted {
                await scheduleNotificationsIfNeeded(for: updated)
            }
        }
        saveDebounced()
        HapticsService.shared.light()
    }

    func clearAll() async {
        items.removeAll()
        await persistence.saveTermins([])
    }

    private func saveDebounced() {
        let snapshot = items
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 150_000_000) // 150ms
            await persistence.saveTermins(snapshot)
        }
    }

    private func scheduleNotificationsIfNeeded(for item: TerminItem) {
        Task {
            _ = await notification.requestAuthorization()
            await notification.scheduleNotifications(for: item,
                                                     dayBeforeAtNine: notifyDayBefore,
                                                     hourBefore: notifyHourBefore)
            // Özel reminder (varsa)
            await notification.scheduleCustomReminder(for: item)
        }
    }
}
