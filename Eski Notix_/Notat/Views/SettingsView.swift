
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var purchaseVM: PurchaseViewModel
    @EnvironmentObject var terminVM: TerminViewModel
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var language: String = Locale.current.identifier
    @State private var showRestartAlert: Bool = false

    private let persistence = PersistenceService()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("app_name")) {
                    HStack {
                        Image(systemName: "person.circle.fill").foregroundColor(.notatBlue)
                        TextField("name", text: $name)
                    }
                    TextField("email", text: $email)
                }

                Section(header: Text("settings_language")) {
                    Picker("settings_language", selection: $language) {
                        Text("Deutsch 🇩🇪").tag("de-DE")
                        Text("Nederlands 🇳🇱").tag("nl-NL")
                        Text("Norsk 🇳🇴").tag("nb-NO")
                        Text("Svenska 🇸🇪").tag("sv-SE")
                        Text("Dansk 🇩🇰").tag("da-DK")
                        Text("Türkçe 🇹🇷").tag("tr-TR")
                        Text("English 🇺🇸").tag("en-US")
                    }
                    .onChange(of: language) { _ in showRestartAlert = true }
                }

                Section(header: Text("settings_notifications")) {
                    Toggle("day_before", isOn: $terminVM.notifyDayBefore)
                    Toggle("hour_before", isOn: $terminVM.notifyHourBefore)
                }

                Section(header: Text("settings_pro")) {
                    if purchaseVM.isPro {
                        Label("activated", systemImage: "checkmark.seal.fill").foregroundColor(.green)
                    } else {
                        NavigationLink(destination: ProUpgradeView()) {
                            HStack { Text("pro_upgrade"); Spacer(); Text("price_label").foregroundColor(.secondary) }
                        }
                    }
                }

                Section(header: Text("settings_about")) {
                    HStack { Text("version"); Spacer(); Text("1.0.0") }
                    HStack { Text("privacy_label"); Spacer(); Text("privacy_label") }
                }

                Section(header: Text("reset_data")) {
                    Button("reset_data", role: .destructive) { Task { await resetAll() } }
                }
            }
            .navigationTitle(Text("einstellungen"))
        }
        .onAppear { Task { await loadProfile() } }
        .alert("einstellungen", isPresented: $showRestartAlert, actions: {
            Button("ok") { }
        }, message: { Text("App language changes require restart.") })
    }

    private func loadProfile() async {
        let dict = await persistence.loadProfile()
        await MainActor.run {
            name = dict["name"] ?? ""
            email = dict["email"] ?? ""
        }
    }

    private func saveProfile() async {
        await persistence.saveProfile(["name": name, "email": email])
    }

    private func resetAll() async {
        await persistence.saveNotes([])
        await persistence.saveTermins([])
        await persistence.saveProfile([:])
    }
}
