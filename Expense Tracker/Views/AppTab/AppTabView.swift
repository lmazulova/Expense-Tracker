//
//  AppTabView.swift
//  Expense Tracker
//
//  Created by user on 18.06.2025.
//

import SwiftUI

struct AppTabView: View {
    @State private var selectedTab: Tab = .outcome
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
                    AccountView()
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
}


#Preview {
    AppTabView()
}
