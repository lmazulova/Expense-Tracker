import SwiftUI

@main
struct Expense_TrackerApp: App {
    private let tabItemSize: Double = 21
    private func setupAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.shadowColor = .gray
        tabBarAppearance.backgroundColor = UIColor.white
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    var body: some Scene {
        WindowGroup {
            AppTabView()
                .onAppear {
                    setupAppearance()
                }
        }
    }
}


