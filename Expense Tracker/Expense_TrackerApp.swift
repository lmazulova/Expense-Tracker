import SwiftUI
import SwiftKeychainWrapper

@main
struct Expense_TrackerApp: App {
    @State private var dataProvider = DataProvider()
    @State private var appMode = AppMode()
    private let tabItemSize: Double = 21
    private func setupAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.shadowColor = .gray
        tabBarAppearance.backgroundColor = UIColor.white
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    init() {
        let tokenKey = "userToken"
        if KeychainWrapper.standard.string(forKey: tokenKey) == nil {
            let token = "zlJGVnAf4UIiblveTO832O6L"
            KeychainWrapper.standard.set(token, forKey: tokenKey)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dataProvider)
                .environment(\.modelContext, dataProvider.context)
                .environment(appMode)
                .onAppear {
                    setupAppearance()
                }
        }
    }
}


