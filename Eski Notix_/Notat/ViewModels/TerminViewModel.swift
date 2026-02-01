
import Foundation

@MainActor
final class TerminViewModel: ObservableObject {
    @Published private(set) var items: [TerminItem] = []
    @Published var showUpgradeBanner: Bool = false
    @Published var showAddSheet: Bool = false
    @Published var editingItem: TerminItem? = nil

    private let persistence = PersistenceService()
    private let notification = NotificationService()

    // Notification toggles
    @Published var notifyDayBefore: Bool = true
    @Published var notifyHourBefore: Bool = true

    func load() {
        Task {
            let loaded = await persistence.loadTermins()
            await MainActor.run { self.items = Self.sort(loaded) }
        }
    }

    var activeCount: Int { items.filter { !$0.isCompleted }.count }

    func canCreate(isPro: Bool) -> Bool {
        if isPro { return true }
        return activeCount < 50
    }

    func create(title: String, dateTime: Date, note: String?, isPro: Bool) {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard canCreate(isPro: isPro) else { showUpgradeBanner = true; return }
        var item = TerminItem(title: title, dateTime: dateTime, note: note, isCompleted: false)
        items.append(item)
        items = Self.sort(items)
        save()
        Task { await notification.scheduleNotifications(for: item, dayBeforeAtNine: notifyDayBefore, hourBefore: notifyHourBefore) }
        HapticsService.shared.success()
    }

    func update(item: TerminItem, title: String, dateTime: Date, note: String?) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        var new = item
        new.title = title
        new.dateTime = dateTime
        new.note = note
        items[idx] = new
        items = Self.sort(items)
        save()
        Task {
            await notification.cancelNotifications(for: item.id)
            if !new.isCompleted { await notification.scheduleNotifications(for: new, dayBeforeAtNine: notifyDayBefore, hourBefore: notifyHourBefore) }
        }
        HapticsService.shared.selection()
    }

    func delete(item: TerminItem) {
        items.removeAll { $0.id == item.id }
        save()
        Task { await notification.cancelNotifications(for: item.id) }
        HapticsService.shared.medium()
    }

    func markComplete(_ item: TerminItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        var done = item
        done.isCompleted = true
        items[idx] = done
        items = Self.sort(items)
        save()
        Task { await notification.cancelNotifications(for: item.id) }
        HapticsService.shared.success()
    }

    func save() {
        Task { await persistence.saveTermins(items) }
    }

    static func sort(_ arr: [TerminItem]) -> [TerminItem] {
        let now = Date()
        return arr.sorted { a, b in
            // Incomplete first
            if a.isCompleted != b.isCompleted { return !a.isCompleted && b.isCompleted }
            // By date ascending
            if a.dateTime != b.dateTime { return a.dateTime < b.dateTime }
            // Same date + same title -> stable sort by creation time
            if a.title == b.title && Calendar.current.isDate(a.dateTime, inSameDayAs: b.dateTime) {
                return a.createdAt < b.createdAt
            }
            // Fallback
            return a.createdAt < b.createdAt
        }
    }
}
