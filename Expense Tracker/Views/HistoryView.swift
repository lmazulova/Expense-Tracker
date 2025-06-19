//
//  HistoryView.swift
//  Expense Tracker
//
//  Created by user on 19.06.2025.
//

import SwiftUI
import OSLog

struct HistoryView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var transactions: [Transaction] = []
    @State private var startDate: Date
    
    @State private var endDate: Date
    
    private let log = OSLog(
        subsystem: "ru.lmazulova.Expense-Tracker",
        category: "HistoryView"
    )
    
    private var sumOfTransactions: Decimal {
        var result: Decimal = 0
        for transaction in transactions {
            result += transaction.amount
        }
        return result
    }
    
    private var transactionService: TransactionsService
    private var direction: Direction
    
    init(transactionService: TransactionsService = TransactionsService(), direction: Direction) {
        let initialStartDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        _startDate = State(initialValue: Calendar.current.startOfDay(for: initialStartDate))
        _endDate = State(initialValue: Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) ?? Date())
        self.transactionService = transactionService
        self.direction = direction
    }
    
    var body: some View {
        VStack {
            List {
                
                HStack {
                    Text("Начало")
                        .font(.system(size: 17, weight: .regular))
                    
                    Spacer()
                    
                    CustomDatePicker(date: $startDate)
                }
                
                HStack {
                    Text("Конец")
                        .font(.system(size: 17, weight: .regular))
                    
                    Spacer()
                    
                    DatePicker("", selection: $endDate, in: ...Date(), displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ru_RU"))
                        .labelsHidden()
                        .background(Color.clear)
                        .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.mintGreen)
                                )
                        .foregroundColor(.black)
                }
                
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
        .navigationBarBackButtonHidden(true)
        .onChange(of: startDate, initial: true) { _, newValue in
            startDate = Calendar.current.startOfDay(for: newValue)
            if startDate > endDate {
                endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: newValue) ?? newValue
            }
            Task {
                await loadTransactions()
            }
        }
        .onChange(of: endDate) { _, newValue in
            endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: newValue) ?? newValue
            if endDate < startDate {
                startDate = Calendar.current.startOfDay(for: newValue)
            }
            Task {
                await loadTransactions()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {dismiss()}) {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .frame(width: 17, height: 22)
                            .foregroundStyle(Color.violet)
                        Text("Назад")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(Color.violet)
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image("analyseButton")
                        .foregroundStyle(Color.violet)
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

    
    

