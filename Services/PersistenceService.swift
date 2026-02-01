
import Foundation

actor PersistenceService {
    enum FileName: String {
        case termins = "termins.json"
        case notes = "notes.json"
        case profile = "profile.json"
    }

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        encoder = JSONEncoder()
        decoder = JSONDecoder()
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    private func fileURL(_ name: FileName) throws -> URL {
        let dir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return dir.appendingPathComponent(name.rawValue)
    }

    func loadTermins() async -> [TerminItem] {
        do {
            let url = try fileURL(.termins)
            guard FileManager.default.fileExists(atPath: url.path) else { return [] }
            let data = try Data(contentsOf: url)
            return try decoder.decode([TerminItem].self, from: data)
        } catch {
            return [] // fallback empty array on error
        }
    }

    func saveTermins(_ items: [TerminItem]) async {
        await atomicWrite(items, to: .termins)
    }

    func loadNotes() async -> [NoteItem] {
        do {
            let url = try fileURL(.notes)
            guard FileManager.default.fileExists(atPath: url.path) else { return [] }
            let data = try Data(contentsOf: url)
            return try decoder.decode([NoteItem].self, from: data)
        } catch { return [] }
    }

    func saveNotes(_ items: [NoteItem]) async { await atomicWrite(items, to: .notes) }

    func loadProfile() async -> [String: String] {
        do {
            let url = try fileURL(.profile)
            guard FileManager.default.fileExists(atPath: url.path) else { return [:] }
            let data = try Data(contentsOf: url)
            return try decoder.decode([String: String].self, from: data)
        } catch { return [:] }
    }

    func saveProfile(_ dict: [String: String]) async { await atomicWrite(dict, to: .profile) }

    private func atomicWrite<T: Encodable>(_ value: T, to name: FileName) async {
        do {
            let url = try fileURL(name)
            let tempURL = url.appendingPathExtension("tmp")
            let data = try encoder.encode(value)
            try data.write(to: tempURL, options: .atomic)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            try FileManager.default.moveItem(at: tempURL, to: url)
        } catch {
            // swallow to avoid crashing; persistence is best-effort
        }
    }
}
