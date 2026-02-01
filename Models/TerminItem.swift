
import Foundation

enum Reminder: Codable, Equatable {
    case minutesBefore(Int)

    private enum CodingKeys: String, CodingKey { case type, minutes }
    private enum Kind: String, Codable { case minutesBefore }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let type = try c.decode(Kind.self, forKey: .type)
        switch type {
        case .minutesBefore:
            let mins = try c.decode(Int.self, forKey: .minutes)
            self = .minutesBefore(mins)
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .minutesBefore(let mins):
            try c.encode(Kind.minutesBefore, forKey: .type)
            try c.encode(mins, forKey: .minutes)
        }
    }
}

struct TerminItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var dateTime: Date
    var note: String?
    var isCompleted: Bool
    let createdAt: Date
    var reminder: Reminder? // yeni: opsiyonel özel hatırlatma

    init(id: UUID = UUID(),
         title: String,
         dateTime: Date,
         note: String? = nil,
         isCompleted: Bool = false,
         createdAt: Date = Date(),
         reminder: Reminder? = nil) {
        self.id = id
        self.title = title
        self.dateTime = dateTime
        self.note = note
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.reminder = reminder
    }

    enum CodingKeys: String, CodingKey {
        case id, title, dateTime, note, isCompleted, createdAt, reminder
    }

    // Ensure id encodes as uuidString and dates in ISO8601
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idString = try container.decode(String.self, forKey: .id)
        guard let uuid = UUID(uuidString: idString) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.id], debugDescription: "Invalid UUID"))
        }
        id = uuid
        title = try container.decode(String.self, forKey: .title)
        dateTime = try container.decode(Date.self, forKey: .dateTime)
        note = try container.decodeIfPresent(String.self, forKey: .note)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        reminder = try container.decodeIfPresent(Reminder.self, forKey: .reminder)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(dateTime, forKey: .dateTime)
        try container.encode(note, forKey: .note)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(reminder, forKey: .reminder)
    }
}

