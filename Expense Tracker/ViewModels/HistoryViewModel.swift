//
//  HistoryViewModel.swift
//  Expense Tracker
//
//  Created by user on 06.07.2025.
//

import SwiftUI

@Observable
final class HistoryViewModel {
    var transactions: [Transaction] = []
    var sortedTransactions: [Transaction] = []
    var startDate: Date {
        didSet {
            Task { await loadTransactions() }
        }
    }
    var endDate: Date {
        didSet {
            Task { await loadTransactions() }
        }
    }
    var direction: Direction
    var showSortView: Bool = false
    private(set) var selectedOption: SortingOption = .none
    private(set) var selectedOrder: SortingOrder = .none
    private var transactionService: TransactionsService
    
    var sumOfTransactions: Decimal {
        transactions.reduce(0) { $0 + $1.amount }
    }
    
    var currency: Currency {
        transactions.first?.account.currency ?? .rub
    }
    
    init(transactionService: TransactionsService, direction: Direction) {
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
        do {
            let transactions = try await transactionService.getTransactions(from: startDate, to: endDate)
                .filter{ $0.category.direction == direction }
            self.transactions = transactions
            sortTransactions()
        } catch {
            print("Ошибка загрузки транзакций - \(error)")
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
