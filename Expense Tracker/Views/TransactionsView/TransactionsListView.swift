//
//  TransactionsListView.swift
//  Expense Tracker
//
//  Created by user on 18.06.2025.
//

import SwiftUI
import OSLog

struct TransactionsListView: View {
    private var direction: Direction
    
    private var startDate: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    private var endDate: Date {
        let calendar = Calendar.current
        let today = Date()
        return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: today) ?? today
    }
    
    private var transactionService = TransactionsService()
    @State private var transactions: [Transaction] = []
    @State private var showHistory: Bool = false
    
    private var sumOfTransactions: Decimal {
        var result: Decimal = 0
        for transaction in transactions {
            result += transaction.amount
        }
        return result
    }
    
    private let log = OSLog(
        subsystem: "ru.lmazulova.Expense-Tracker",
        category: "TransactionParser"
    )
    
    init(direction: Direction) {
        self.direction = direction
    }
    
    var body: some View {
        VStack {
            List {
                HStack {
                    Text("Всего")
                        .font(.system(size: 17, weight: .regular))
                    
                    Spacer()
                    
                    Text("\(sumOfTransactions) \(transactions.first?.account.currency.rawValue ?? "")")
                        .font(.system(size: 17, weight: .regular))
                }
                
                Section("Операции") {
                    ForEach(transactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                }
            }
        }
        .navigationDestination(isPresented: $showHistory) {
            HistoryView(transactionService: transactionService, direction: direction)
                .navigationTitle("Моя история")
        }
        .onAppear {
            Task {
                await loadTransactions()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showHistory = true }) {
                    Image("historyButton")
                }
            }
        }
    }
    private func loadTransactions() async {
        do {
            transactions = try await transactionService.getTransactions(from: startDate, to: endDate)
                .filter{ $0.category.direction == direction }
        }
        catch {
            os_log("‼️ Ошибка загрузки транзакций.",
                   log: log,
                   type: .error)
            
            transactions = []
        }
    }
}

#Preview {
    TransactionsListView(direction: .income)
}
