
import SwiftUI

@main
struct NotatApp: App {
    @StateObject private var purchaseVM = PurchaseViewModel()
    @StateObject private var terminVM = TerminViewModel()
    @StateObject private var notesVM = NotesViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(purchaseVM)
                .environmentObject(terminVM)
                .environmentObject(notesVM)
        }
    }
}
