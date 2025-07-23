import SwiftUI

struct AppTabView: View {
    @State private var selectedTab: Tab = .outcome
    @Environment(AppMode.self) private var appMode
    
    private let tabItemSize: Double = 21
    
    enum Tab: String, CaseIterable {
        case outcome
        case income
        case account
        case categories
        case settings
        
        var title: String {
            switch self {
            case .outcome:
                return "Расходы"
            case .income:
                return "Доходы"
            case .account:
                return "Счет"
            case .categories:
                return "Статьи"
            case .settings:
                return "Настройки"
            }
        }
        
        @ViewBuilder
        var view: some View {
            switch self {
            case .outcome:
                NavigationStack {
                    TransactionsListView(direction: .outcome)
                        .navigationTitle("Расходы сегодня")
                }
            case .income:
                NavigationStack {
                    TransactionsListView(direction: .income)
                        .navigationTitle("Доходы сегодня")
                }
            case .account:
                NavigationStack {
                    BankAccountView()
                        .navigationTitle("Мой счет")
                }
            case .categories:
                NavigationStack {
                    CategoriesView()
                        .navigationTitle("Мои статьи")
                }
            case .settings:
                NavigationStack {
                    SettingsView()
                        .navigationTitle("Настройки")
                }
            }
        }
    }
    
    
    
    var body: some View {
        VStack(spacing: 0) {
            if appMode.isOffline {
                Text("Вы в офлайн режиме")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.red)
                    .transition(.move(edge: .top))
            }

            TabView(selection: $selectedTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    tab.view
                        .tabItem(){
                            Label {
                                Text(tab.title)
                            } icon: {
                                Image(tab.rawValue)
                                    .renderingMode(.template)
                                    .frame(width: tabItemSize, height: tabItemSize)
                            }
                        }
                        .tag(tab)
                }
            }
        }
        .animation(.easeInOut, value: appMode.isOffline)
    }
}


#Preview {
    AppTabView()
}
