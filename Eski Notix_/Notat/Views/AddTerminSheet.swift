
import SwiftUI

struct AddTerminSheet: View {
    @EnvironmentObject var terminVM: TerminViewModel
    @EnvironmentObject var purchaseVM: PurchaseViewModel

    var editing: TerminItem? = nil

    @State private var title: String = ""
    @State private var dateTime: Date = Date()
    @State private var note: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("termin_title", text: $title)
                    DatePicker("termin_date", selection: $dateTime)
                    TextField("termin_note", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(Text(editing == nil ? "create_new" : "edit"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("close") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        if let e = editing {
                            terminVM.update(item: e, title: title, dateTime: dateTime, note: note.isEmpty ? nil : note)
                        } else {
                            terminVM.create(title: title, dateTime: dateTime, note: note.isEmpty ? nil : note, isPro: purchaseVM.isPro)
                        }
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let e = editing {
                    title = e.title; dateTime = e.dateTime; note = e.note ?? ""
                }
            }
        }
    }
}
