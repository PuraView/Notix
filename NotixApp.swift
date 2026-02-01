
import SwiftUI

@main
struct NotixApp: App {
    @StateObject private var purchaseVM = PurchaseViewModel()
    @StateObject private var terminVM = TerminViewModel()
    @StateObject private var notesVM = NotesViewModel()

    @AppStorage("themeMode") private var themeMode: String = "system"

    private var colorScheme: ColorScheme? {
        switch themeMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil // system
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(purchaseVM)
                .environmentObject(terminVM)
                .environmentObject(notesVM)
                .preferredColorScheme(colorScheme)
        }
    }
}

