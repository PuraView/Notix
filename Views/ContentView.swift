import SwiftUI

struct ContentView: View {
    @EnvironmentObject var terminVM: TerminViewModel
    @EnvironmentObject var notesVM: NotesViewModel
    @EnvironmentObject var purchaseVM: PurchaseViewModel

    @State private var tab: MainTab = .termin
    @State private var showSettings: Bool = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TopNavigationBar { showSettings = true }
                CustomSegmentedControl(selection: $tab)
                TabView(selection: $tab) {
                    TerminListView()
                        .tag(MainTab.termin)
                    NotizListView()
                        .tag(MainTab.notiz)
                }
                .tabViewStyle(.page(indexDisplayMode: .never)) // iOS page style
            }

            // Floating Action Button (FAB)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        if tab == .termin { terminVM.showAddSheet = true } else { notesVM.showAddSheet = true }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color(hex: "#4fd1c5"))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 8)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
            .ignoresSafeArea(edges: .bottom)
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
        .sheet(isPresented: $terminVM.showAddSheet) {
            AddTerminSheet()
        }
        .sheet(isPresented: $notesVM.showAddSheet) {
            AddNoteSheet(editing: nil)
        }
        .background(Color(UIColor.systemBackground))
    }
}
