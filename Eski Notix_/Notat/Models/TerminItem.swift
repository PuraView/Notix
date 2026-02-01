
import Foundation

struct TerminItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var dateTime: Date
    var note: String?
    var isCompleted: Bool
    let createdAt: Date

    init(id: UUID = UUID(), title: String, dateTime: Date, note: String? = nil, isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.dateTime = dateTime
        self.note = note
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id, title, dateTime, note, isCompleted, createdAt
    }

    // Ensure id encodes as uuidString and dates in ISO8601
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idString = try container.decode(String.self, forKey: .id)
        guard let uuid = UUID(uuidString: idString) else { throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.id], debugDescription: "Invalid UUID")) }
        id = uuid
        title = try container.decode(String.self, forKey: .title)
        dateTime = try container.decode(Date.self, forKey: .dateTime)
        note = try container.decodeIfPresent(String.self, forKey: .note)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(dateTime, forKey: .dateTime)
        try container.encode(note, forKey: .note)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(createdAt, forKey: .createdAt)
    }
}
