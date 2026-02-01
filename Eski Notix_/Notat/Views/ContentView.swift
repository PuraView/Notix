
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var terminVM: TerminViewModel
    @EnvironmentObject var notesVM: NotesViewModel
    @EnvironmentObject var purchaseVM: PurchaseViewModel

    @State private var tab: MainTab = .termin
    @State private var showSettings: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            TopNavigationBar { showSettings = true }
            CustomSegmentedControl(selection: $tab)
            TabView(selection: $tab) {
                TerminListView()
                    .tag(MainTab.termin)
                NotizListView()
                    .tag(MainTab.notiz)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .onAppear {
            purchaseVM.onAppear()
            terminVM.load()
            notesVM.load()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(purchaseVM)
                .presentationDetents([.medium, .large])
        }
        .overlay(alignment: .bottom) {
            AddButton(titleKey: "neue_erstellen") {
                if tab == .termin { terminVM.showAddSheet = true } else { notesVM.showAddSheet = true }
            }
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $terminVM.showAddSheet) {
            AddTerminSheet()
        }
        .sheet(isPresented: $notesVM.showAddSheet) {
            AddNoteSheet()
        }
        .background(Color.bgPrimary)
    }
}
