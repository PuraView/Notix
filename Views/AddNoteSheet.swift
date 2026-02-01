import SwiftUI

struct AddNoteSheet: View {
    @EnvironmentObject var notesVM: NotesViewModel
    @Environment(\.colorScheme) private var colorScheme

    var editing: NoteItem?
    @State private var text: String = ""

    // Auto-save
    @State private var createdItemID: UUID? = nil
    @State private var debounceTask: Task<Void, Never>? = nil

    init(editing: NoteItem?) { self.editing = editing }

    private var hasMeaningfulInput: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var bgGradient: LinearGradient {
        if colorScheme == .dark {
            LinearGradient(
                colors: [Color(hex: "#1a2e2c"), Color(hex: "#152423"), Color(hex: "#0f1a19")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            Color.screenGradientTeal
        }
    }

    private var headerColor: Color { colorScheme == .dark ? .white : .primary }
    private var inputTextColor: Color { colorScheme == .dark ? .white : .primary }

    var body: some View {
        NavigationView {
            ZStack {
                Color.clear
                    .background(bgGradient)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text(editing == nil ? String(localized: "create_new") : String(localized: "edit"))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(headerColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 12) {
                            TextField("", text: $text, axis: .vertical)
                                .lineLimit(8...14)
                                .textFieldStyle(.plain)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(inputTextColor)
                                .padding(14)
                                .background(Color.formBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.formBorder, lineWidth: 1)
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.formShadow, radius: 8, x: 0, y: 2)
                        }
                        .padding(.horizontal, 20)

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
            .onAppear {
                if let e = editing {
                    text = e.text
                    createdItemID = e.id
                }
            }
            .onDisappear { saveDebounced(immediate: true) }
            .onChange(of: text) { _ in saveDebounced() }
        }
        .interactiveDismissDisabled(false)
    }

    // MARK: - Auto-save
    private func saveDebounced(immediate: Bool = false) {
        debounceTask?.cancel()
        debounceTask = Task { [text] in
            if !immediate { try? await Task.sleep(nanoseconds: 700_000_000) }
            await saveNowSnapshot(text: text)
        }
    }

    @MainActor
    private func saveNowSnapshot(text: String) async {
        guard hasMeaningfulInput || createdItemID != nil else { return }

        if let id = createdItemID, let existing = notesVM.items.first(where: { $0.id == id }) {
            notesVM.update(item: existing, text: text)
        } else {
            guard hasMeaningfulInput else { return }
            notesVM.create(text: text)
            createdItemID = notesVM.items.last?.id
        }
    }
}

