import Foundation
import SwiftUI
import Combine

@MainActor
final class NotesViewModel: ObservableObject {
    @Published private(set) var items: [NoteItem] = []
    @Published var showAddSheet: Bool = false
    @Published var editingItem: NoteItem? = nil

    private let persistence = PersistenceService()
    private var saveTask: Task<Void, Never>? = nil

    func load() {
        Task {
            let loaded = await persistence.loadNotes()
            await MainActor.run {
                self.items = loaded.sorted { $0.position < $1.position }
            }
        }
    }

    func create(text: String) {
        let pos = (items.map { $0.position }.max() ?? 0) + 10
        let item = NoteItem(text: text, position: pos)
        items.append(item)
        saveDebounced()
        HapticsService.shared.success()
    }

    func update(item: NoteItem, text: String) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        var new = item
        new.text = text
        items[idx] = new
        saveDebounced()
        HapticsService.shared.selection()
    }

    func delete(item: NoteItem) {
        items.removeAll { $0.id == item.id }
        saveDebounced()
        HapticsService.shared.medium()
    }

    func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
        // Reassign positions with gaps to keep stability
        for (i, _) in items.enumerated() {
            items[i].position = (i + 1) * 10
        }
        saveDebounced()
    }

    // Tüm notları temizlemek için dışarıya açık, güvenli API
    func clearAll() async {
        // 1) Belleği boşalt
        items.removeAll()
        // 2) Diske yaz
        await persistence.saveNotes([])
    }

    private func saveDebounced() {
        saveTask?.cancel()
        saveTask = Task { [items] in
            try? await Task.sleep(nanoseconds: 150_000_000) // 150ms
            await PersistenceService().saveNotes(items)
        }
    }
}
