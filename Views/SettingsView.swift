import SwiftUI
import UserNotifications
import StoreKit

#if canImport(UIKit)
import UIKit
#endif

struct SettingsView: View {
    @EnvironmentObject var purchaseVM: PurchaseViewModel
    @EnvironmentObject var terminVM: TerminViewModel
    @EnvironmentObject var notesVM: NotesViewModel
    @Environment(\.colorScheme) private var colorScheme

    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    @AppStorage("themeMode") private var themeMode: String = "system"

    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var showResetConfirm: Bool = false

    private let persistence = PersistenceService()

    private var versionString: String {
        let ver = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return build.isEmpty ? ver : "\(ver) (\(build))"
    }

    // Ürün fiyatı (yüklüyse)
    private var displayPrice: String {
        if let p = purchaseVM.product {
            return p.displayPrice
        } else {
            return "4,99 €"
        }
    }

    // Gerçek limit kaynağı: TerminViewModel ile aynı değeri kullan
    private var terminFreeLimit: Int { 10 }

    // Kullanım özeti: Notlar sınırsız olduğundan yalnızca Termin bilgisini göster
    private var usageSummary: String {
        let key = String(localized: "usage_summary_termin_only", defaultValue: "Appointments: %d/%d")
        return String(format: key, terminVM.items.count, terminFreeLimit)
    }

    private var notificationStatusText: String {
        switch notificationStatus {
        case .authorized, .provisional, .ephemeral: return String(localized: "notifications_enabled")
        case .denied: return String(localized: "notifications_disabled")
        case .notDetermined: return String(localized: "notifications_not_requested")
        @unknown default: return String(localized: "notifications_status_unknown")
        }
    }

    private var bgGradient: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [Color(hex: "#1a2e2c"), Color(hex: "#152423"), Color(hex: "#0f1a19")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return Color.screenGradientTeal
        }
    }

    private var lightRowBackground: Color { Color.formBackground }
    private var darkTealRowBackground: Color { Color(hex: "#4FD1C5").opacity(0.18) }

    var body: some View {
        NavigationView {
            ZStack {
                Color.clear
                    .background(bgGradient)
                    .ignoresSafeArea()

                Form {
                    Section(header: Text(LocalizedStringKey("appearance"))) {
                        Picker(String(localized: "theme"), selection: $themeMode) {
                            Text(LocalizedStringKey("system")).tag("system")
                            Text(LocalizedStringKey("light")).tag("light")
                            Text(LocalizedStringKey("dark")).tag("dark")
                        }
                        .pickerStyle(.segmented)
                        .listRowBackground(colorScheme == .dark ? darkTealRowBackground : lightRowBackground)
                    }
                    .listRowBackground(colorScheme == .dark ? darkTealRowBackground : lightRowBackground)

                    Section(header: Text(LocalizedStringKey("haptics"))) {
                        Toggle(isOn: $hapticsEnabled) {
                            Text(LocalizedStringKey("enable_haptics"))
                        }
                        .listRowBackground(colorScheme == .dark ? darkTealRowBackground : lightRowBackground)
                    }
                    .listRowBackground(colorScheme == .dark ? darkTealRowBackground : lightRowBackground)

                    Section(
                        header: Text(LocalizedStringKey("notifications")),
                        footer: Text(notificationStatusText)
                    ) {
                        Toggle(isOn: $terminVM.notifyDayBefore) {
                            Text(LocalizedStringKey("notif_day_before"))
                        }
                        .onChange(of: terminVM.notifyDayBefore) { newValue in
                            if newValue { requestNotificationPermission() }
                        }
                        .listRowBackground(colorScheme == .dark ? darkTealRowBackground : lightRowBackground)

                        Toggle(isOn: $terminVM.notifyHourBefore) {
                            Text(LocalizedStringKey("notif_hour_before"))
                        }
                        .onChange(of: terminVM.notifyHourBefore) { newValue in
                            if newValue { requestNotificationPermission() }
                        }
                        .listRowBackground(colorScheme == .dark ? darkTealRowBackground : lightRowBackground)

                        if notificationStatus == .denied || notificationStatus == .notDetermined {
                            Button {
                                openAppSettings()
                            } label: {
                                Label {
                                    Text(LocalizedStringKey("open_ios_notification_settings"))
                                } icon: {
                                    Image(systemName: "gear")
                                }
                            }
                            .listRowBackground(colorScheme == .dark ? darkTealRowBackground : lightRowBackground)
                        }
                    }
                    .listRowBackground(colorScheme == .dark ? darkTealRowBackground : lightRowBackground)

                    Section(header: Text(LocalizedStringKey("pro_version_header"))) {
                        if purchaseVM.isPro {
                            Label {
                                Text(LocalizedStringKey("activated"))
                            } icon: {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                            }
                            .foregroundColor(.green)
                            .listRowBackground(colorScheme == .dark ? darkTealRowBackground : lightRowBackground)

                            Text(LocalizedStringKey("unlimited_unlocked"))
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .listRowBackground(colorScheme == .dark ? darkTealRowBackground : lightRowBackground)
                        } else {
                            // Ürün yoksa (App Review cihazında da olabilir) kartı gizle -> "incomplete" izlenimi olmasın
                            if let _ = purchaseVM.product {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text(LocalizedStringKey("pro_version_title"))
                                            .font(.headline)
                                        Spacer()
                                        Text(String(format: NSLocalizedString("one_time_price_format", comment: ""), displayPrice))
                                            .foregroundColor(.secondary)
                                    }

                                    HStack(spacing: 12) {
                                        Button {
                                            Task { await purchaseVM.purchase() }
                                        } label: {
                                            Text(String(format: NSLocalizedString("open_pro_with_price", comment: ""), displayPrice))
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(.borderedProminent)

                                        Button {
                                            Task { await purchaseVM.restore() }
                                        } label: {
                                            Text(LocalizedStringKey("restore_purchase"))
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(.bordered)
                                        .tint(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)

                                    // DEBUG ortamı dışında placeholder metin gösterme
                                    #if DEBUG
                                    if purchaseVM.product == nil {
                                        Text("Product not loaded. Use StoreKit Configuration or add IAP in App Store Connect.")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                    #endif

                                    Text(usageSummary)
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                                .listRowBackground(colorScheme == .dark ? darkTealRowBackground : lightRowBackground)
                            } else {
                                // Ürün yüklenmediyse Release'te hiçbir şey gösterme; sadece kullanım bilgisini ver
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(usageSummary)
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                                .listRowBackground(colorScheme == .dark ? darkTealRowBackground : lightRowBackground)
                            }
                        }
                    }
                    .listRowBackground(colorScheme == .dark ? darkTealRowBackground : lightRowBackground)

                    Section(header: Text(LocalizedStringKey("about"))) {
                        HStack {
                            Text(LocalizedStringKey("version"))
                            Spacer()
                            Text(versionString)
                        }
                        .listRowBackground(colorScheme == .dark ? darkTealRowBackground : lightRowBackground)

                        Link(destination: URL(string: "https://PuraView.github.io/Notix/privacy.html")!) {
                            HStack {
                                Text(LocalizedStringKey("privacy_policy"))
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .listRowBackground(colorScheme == .dark ? darkTealRowBackground : lightRowBackground)

                        Link(destination: URL(string: "https://PuraView.github.io/Notix/")!) {
                            HStack {
                                Text(LocalizedStringKey("terms_of_use"))
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .listRowBackground(colorScheme == .dark ? darkTealRowBackground : lightRowBackground)

                        Button {
                            requestReview()
                        } label: {
                            HStack {
                                Text(LocalizedStringKey("rate_this_app"))
                                Spacer()
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                        .listRowBackground(colorScheme == .dark ? darkTealRowBackground : lightRowBackground)
                    }
                    .listRowBackground(colorScheme == .dark ? darkTealRowBackground : lightRowBackground)

                    Section(header: Text(LocalizedStringKey("delete_all_data"))) {
                        Button(role: .destructive) {
                            showResetConfirm = true
                        } label: {
                            Text(LocalizedStringKey("delete_all_data"))
                        }
                        .listRowBackground(colorScheme == .dark ? darkTealRowBackground : lightRowBackground)
                    }
                    .listRowBackground(colorScheme == .dark ? darkTealRowBackground : lightRowBackground)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
                .environment(\.defaultMinListRowHeight, 44)
                .onAppear {
                    #if canImport(UIKit)
                    UITableView.appearance().backgroundColor = .clear
                    if colorScheme == .light {
                        UITableViewCell.appearance().backgroundColor = UIColor(Color.formBackground)
                    } else {
                        UITableViewCell.appearance().backgroundColor = UIColor(darkTealRowBackground)
                    }
                    #endif
                }
                .onDisappear {
                    #if canImport(UIKit)
                    UITableView.appearance().backgroundColor = nil
                    UITableViewCell.appearance().backgroundColor = nil
                    #endif
                }
            }
            .navigationTitle(Text(LocalizedStringKey("einstellungen")))
        }
        .onAppear { refreshNotificationStatus() }
        .alert(
            Text(LocalizedStringKey("delete_all_data")),
            isPresented: $showResetConfirm
        ) {
            Button(role: .cancel) { } label: {
                Text(LocalizedStringKey("cancel"))
            }
            Button(role: .destructive) {
                Task { await resetAll() }
            } label: {
                Text(LocalizedStringKey("delete"))
            }
        } message: {
            Text(LocalizedStringKey("delete_all_data_message"))
        }
    }

    // MARK: - Helpers
    private func refreshNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationStatus = settings.authorizationStatus
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
            refreshNotificationStatus()
        }
    }

    private func openAppSettings() {
        #if canImport(UIKit)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #endif
    }

    private func requestReview() {
        #if canImport(UIKit)
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            SKStoreReviewController.requestReview(in: scene)
        } else {
            SKStoreReviewController.requestReview()
        }
        #else
        SKStoreReviewController.requestReview()
        #endif
    }

    private func resetAll() async {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        await terminVM.clearAll()
        await notesVM.clearAll()
        await persistence.saveProfile([:])
    }
}
