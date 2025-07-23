//
//  TransactionListViewModel.swift
//  Expense Tracker
//
//  Created by user on 18.07.2025.
//

import SwiftUI
import OSLog

@MainActor
@Observable
final class TransactionListViewModel {
    
    private let log = OSLog(
        subsystem: "ru.lmazulova.Expense-Tracker",
        category: "TransactionParser"
    )
    
    var state: LoadingState = .loading
    private(set) var transactions: [Transaction] = []
    var transactionsService: TransactionsService?
    var categoriesService: CategoriesService?
    var direction: Direction
    
    var sumOfTransactions: Decimal {
        transactions.reduce(0) { $0 + $1.amount }
    }
    
    private var startDate: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    private var endDate: Date {
        let calendar = Calendar.current
        let today = Date()
        return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: today) ?? today
    }
    
    init(direction: Direction, transactionsService: TransactionsService? = nil, categoriesService: CategoriesService? = nil) {
        self.direction = direction
        self.transactionsService = transactionsService
        self.categoriesService = categoriesService
    }
    
    func loadTransactions() async {
        state = .loading
        guard let transactionsService = transactionsService else {
            os_log("‼️ TransactionsService не инициализирован.",
                   log: log,
                   type: .error)
            transactions = []
            return
        }
        
        do {
            transactions = try await transactionsService.getTransactions(from: startDate, to: endDate)
                .filter{ $0.category.direction == direction }
            state = .data
        }
        catch {
            os_log("‼️ Ошибка загрузки транзакций.",
                   log: log,
                   type: .error)
            print(error.localizedDescription)
            transactions = []
            state = .error(error.localizedDescription)
        }
    }
}

