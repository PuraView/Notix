
import Foundation

struct NoteItem: Identifiable, Codable, Equatable {
    let id: UUID
    var text: String
    var position: Int
    let createdAt: Date

    init(id: UUID = UUID(), text: String, position: Int, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.position = position
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey { case id, text, position, createdAt }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let idString = try c.decode(String.self, forKey: .id)
        guard let uuid = UUID(uuidString: idString) else { throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.id], debugDescription: "Invalid UUID")) }
        id = uuid
        text = try c.decode(String.self, forKey: .text)
        position = try c.decode(Int.self, forKey: .position)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id.uuidString, forKey: .id)
        try c.encode(text, forKey: .text)
        try c.encode(position, forKey: .position)
        try c.encode(createdAt, forKey: .createdAt)
    }
}
