
import Foundation
import UserNotifications

actor NotificationService {
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch { return false }
    }

    func cancelNotifications(for terminID: UUID) async {
        let base = "termin_\(terminID.uuidString)"
        let ids = ["\(base)_day", "\(base)_hour"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ids)
    }

    func scheduleNotifications(for item: TerminItem, dayBeforeAtNine: Bool, hourBefore: Bool) async {
        let center = UNUserNotificationCenter.current()
        let base = "termin_\(item.id.uuidString)" // spec requires this base

        if dayBeforeAtNine {
            if let triggerDate = Self.oneDayBeforeNine(of: item.dateTime) {
                let content = UNMutableNotificationContent()
                content.title = item.title
                if let note = item.note { content.body = note }
                content.sound = .default
                let trigger = UNCalendarNotificationTrigger(dateMatching: Self.components(from: triggerDate), repeats: false)
                let request = UNNotificationRequest(identifier: "\(base)_day", content: content, trigger: trigger)
                do { try await center.add(request) } catch {}
            }
        }

        if hourBefore {
            if let triggerDate = Calendar.current.date(byAdding: .hour, value: -1, to: item.dateTime), triggerDate > Date() {
                let content = UNMutableNotificationContent()
                content.title = item.title
                if let note = item.note { content.body = note }
                content.sound = .default
                let trigger = UNCalendarNotificationTrigger(dateMatching: Self.components(from: triggerDate), repeats: false)
                let request = UNNotificationRequest(identifier: "\(base)_hour", content: content, trigger: trigger)
                do { try await center.add(request) } catch {}
            }
        }
    }

    private static func oneDayBeforeNine(of date: Date) -> Date? {
        let cal = Calendar.current
        guard let dayBefore = cal.date(byAdding: .day, value: -1, to: date) else { return nil }
        var comps = cal.dateComponents([.year, .month, .day], from: dayBefore)
        comps.hour = 9
        comps.minute = 0
        comps.second = 0
        return cal.date(from: comps).flatMap { $0 > Date() ? $0 : nil }
    }

    private static func components(from date: Date) -> DateComponents {
        let cal = Calendar.current
        return cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
    }
}
