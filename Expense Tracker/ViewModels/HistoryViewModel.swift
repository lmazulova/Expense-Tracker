//
//  HistoryViewModel.swift
//  Expense Tracker
//
//  Created by user on 06.07.2025.
//

import SwiftUI

@Observable
final class HistoryViewModel {
    var state: LoadingState = .loading
    var transactions: [Transaction] = []
    var sortedTransactions: [Transaction] = []
    var startDate: Date {
        didSet {
            validateDates()
            Task { await loadTransactions() }
        }
    }
    var endDate: Date {
        didSet {
            validateDates()
            Task { await loadTransactions() }
        }
    }
    var direction: Direction
    var showSortView: Bool = false
    private(set) var selectedOption: SortingOption = .none
    private(set) var selectedOrder: SortingOrder = .none
    private var transactionService: TransactionsService?
    
    var sumOfTransactions: Decimal {
        transactions.reduce(0) { $0 + $1.amount }
    }
    
    var currency: Currency {
        transactions.first?.account.currency ?? .rub
    }
    
    init(transactionService: TransactionsService?, direction: Direction) {
        let initialStartDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        self.startDate = Calendar.current.startOfDay(for: initialStartDate)
        self.endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) ?? Date()
        self.selectedOption = .none
        self.selectedOrder = .none
        self.transactionService = transactionService
        self.direction = direction
    }
    
    func resetFilters() {
        selectedOption = .none
        selectedOrder = .none
        showSortView = false
        sortTransactions()
    }
    
    func setFilters(option: SortingOption?, order: SortingOrder?) {
        guard let option = option, let order = order else {
            resetFilters()
            return
        }
        selectedOption = option
        selectedOrder = order
        showSortView = false
        sortTransactions()
    }
    
    func loadTransactions() async {
        state = .loading
        guard let transactionService = transactionService else {
            print("TransactionService не инициализирован")
            state = .error("Сервис транзакций не инициализирован")
            return
        }
        do {
            let transactions = try await transactionService.getTransactions(from: startDate, to: endDate)
                .filter{ $0.category.direction == direction }
            self.transactions = transactions
            sortTransactions()
            state = .data
        } catch {
            print("Ошибка загрузки транзакций - \(error)")
            state = .error(error.localizedDescription)
        }
    }
    
    private func validateDates() {
        if startDate > endDate {
            endDate = startDate
        } else if endDate < startDate {
            startDate = endDate
        }
    }
    
    private func sortTransactions() {
        //Применяем фильтрацию по выбранной категории
        switch selectedOption {
        case .date:
            switch selectedOrder {
            case .ascending:
                self.sortedTransactions = transactions.sorted { $0.transactionDate < $1.transactionDate }
            case .descending:
                self.sortedTransactions = transactions.sorted { $0.transactionDate > $1.transactionDate }
            case .none:
                self.sortedTransactions = transactions
            }
        case .amount:
            switch selectedOrder {
            case .ascending:
                self.sortedTransactions = transactions.sorted { $0.amount < $1.amount }
            case .descending:
                self.sortedTransactions = transactions.sorted { $0.amount > $1.amount }
            case .none:
                self.sortedTransactions = transactions
            }
        case .none:
            self.sortedTransactions = transactions
        }
    }
}
