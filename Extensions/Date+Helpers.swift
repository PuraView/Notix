
import Foundation

extension Date {
    var isTodayLocal: Bool {
        Calendar.current.isDateInToday(self)
    }
    var isPast: Bool { self < Date() }

    func formattedShort() -> String {
        let df = DateFormatter()
        df.locale = Locale.current
        df.timeZone = TimeZone.current
        df.dateFormat = "dd.MM.yyyy - HH:mm"
        return df.string(from: self)
    }
}
