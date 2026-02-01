import SwiftUI

struct AddTerminSheet: View {
    @EnvironmentObject var terminVM: TerminViewModel
    @EnvironmentObject var purchaseVM: PurchaseViewModel
    @Environment(\.colorScheme) private var colorScheme

    var editing: TerminItem? = nil

    @State private var title: String = ""
    @State private var dateTime: Date = Date()
    @State private var note: String = ""

    // Reminder UI state
    @State private var reminderEnabled: Bool = false
    @State private var reminderMinutes: Int = 30
    private let reminderOptions: [Int] = [5, 10, 30, 60]

    // Auto-save state
    @State private var createdItemID: UUID? = nil
    @State private var debounceTask: Task<Void, Never>? = nil

    private var currentReminder: Reminder? {
        reminderEnabled ? .minutesBefore(reminderMinutes) : nil
    }
    private var trimmedTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var hasMeaningfulInput: Bool { !trimmedTitle.isEmpty }

    // MARK: - Theming helpers (light/dark)
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
    private var labelColor: Color { colorScheme == .dark ? Color(hex: "#999999") : .secondary }
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

                        VStack(alignment: .leading, spacing: 2) {
                            // Title
                            VStack(alignment: .leading, spacing: 2) {
                                Text("termin_title")
                                    .font(.subheadline)
                                    .foregroundColor(labelColor)
                                TextField("", text: $title)
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

                            // Date & Time
                            VStack(alignment: .leading, spacing: 2) {
                                Text("termin_date")
                                    .font(.subheadline)
                                    .foregroundColor(labelColor)
                                DatePicker("", selection: $dateTime, displayedComponents: [.date, .hourAndMinute])
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
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

                            // Note
                            VStack(alignment: .leading, spacing: 2) {
                                Text("termin_note")
                                    .font(.subheadline)
                                    .foregroundColor(labelColor)
                                TextField("", text: $note, axis: .vertical)
                                    .lineLimit(4...8)
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

                            // Reminder
                            VStack(alignment: .leading, spacing: 2) {
                                Toggle(isOn: $reminderEnabled) {
                                    Text(LocalizedStringKey("reminder"))
                                        .foregroundColor(inputTextColor)
                                }
                                .tint(.segmentActive)

                                if reminderEnabled {
                                    Menu {
                                        Picker(selection: $reminderMinutes) {
                                            ForEach(reminderOptions, id: \.self) { m in
                                                let unit = String(localized: "minutes_before")
                                                let format = String(localized: "minutes_before_format", defaultValue: "%d %@")
                                                Text(String(format: format, m, unit)).tag(m)
                                            }
                                        } label: { EmptyView() }
                                    } label: {
                                        HStack {
                                            let unit = String(localized: "minutes_before")
                                            let format = String(localized: "minutes_before_format", defaultValue: "%d %@")
                                            Text(String(format: format, reminderMinutes, unit))
                                                .font(.body)
                                                .foregroundColor(inputTextColor)
                                            Spacer()
                                            Image(systemName: "chevron.up.chevron.down")
                                                .font(.footnote)
                                                .foregroundColor(labelColor)
                                        }
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 12)
                                        .background(Color.formBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.formBorder, lineWidth: 1)
                                        )
                                        .cornerRadius(12)
                                        .shadow(color: Color.formShadow, radius: 8, x: 0, y: 2)
                                    }
                                }
                            }
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
                    title = e.title
                    dateTime = e.dateTime
                    note = e.note ?? ""
                    if let r = e.reminder, case .minutesBefore(let mins) = r {
                        reminderEnabled = true
                        reminderMinutes = mins
                    } else {
                        reminderEnabled = false
                    }
                    createdItemID = e.id
                }
            }
            .onDisappear { saveDebounced(immediate: true) }
            .onChange(of: title) { _ in saveDebounced() }
            .onChange(of: dateTime) { _ in saveDebounced() }
            .onChange(of: note) { _ in saveDebounced() }
            .onChange(of: reminderEnabled) { _ in saveDebounced() }
            .onChange(of: reminderMinutes) { _ in if reminderEnabled { saveDebounced() } }
        }
        .interactiveDismissDisabled(false)
    }

    // MARK: - Auto-save
    private func saveDebounced(immediate: Bool = false) {
        debounceTask?.cancel()
        debounceTask = Task { [title, dateTime, note, reminderEnabled, reminderMinutes] in
            if !immediate { try? await Task.sleep(nanoseconds: 700_000_000) }
            await saveNowSnapshot(title: title,
                                  dateTime: dateTime,
                                  note: note,
                                  reminderEnabled: reminderEnabled,
                                  reminderMinutes: reminderMinutes)
        }
    }

    @MainActor
    private func saveNowSnapshot(title: String,
                                 dateTime: Date,
                                 note: String,
                                 reminderEnabled: Bool,
                                 reminderMinutes: Int) async {
        let reminder: Reminder? = reminderEnabled ? .minutesBefore(reminderMinutes) : nil
        guard hasMeaningfulInput || createdItemID != nil else { return }

        if let id = createdItemID, let existing = terminVM.items.first(where: { $0.id == id }) {
            terminVM.update(item: existing,
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            dateTime: dateTime,
                            note: note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : note,
                            reminder: reminder)
        } else {
            guard hasMeaningfulInput else { return }
            if let created = terminVM.create(title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                                             dateTime: dateTime,
                                             note: note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : note,
                                             isPro: purchaseVM.isPro,
                                             reminder: reminder) {
                createdItemID = created.id
            }
        }
    }
}
