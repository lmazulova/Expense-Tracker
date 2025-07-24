//
//  MankAccountViewModel.swift
//  Expense Tracker
//
//  Created by user on 04.07.2025.
//

import SwiftUI

@MainActor
@Observable
final class BankAccountViewModel {
    var bankAccountService: BankAccountService?
    var transactionsService: TransactionsService?
    
    var state: LoadingState = .loading
    var isEditMode: Bool = false
    private(set) var account: BankAccount?
    private(set) var dailyBalance: [DailyBalance]?
    
    init(bankAccountService: BankAccountService? = nil, transactionsService: TransactionsService? = nil) {
        self.bankAccountService = bankAccountService
        self.transactionsService = transactionsService
    }
    
    func toggleEditMode() {
        withAnimation {
            isEditMode.toggle()
        }
    }
    
    func loadAccount() async {
        state = .loading
        guard let bankAccountService else {
            print("BankAccountService не инициализирован")
            state = .error("Сервис банковского аккаунта не инициализирован")
            return
        }
        do {
            let account = try await bankAccountService.currentAccount()
            self.account = account
            state = .data
        } catch {
            print("Ошибка при загрузке акаунта: \(error)")
            state = .error(error.localizedDescription)
        }
    }
    
    func loadDailyBalance() async {
        state = .loading
        guard let transactionsService else {
            print("TransactionsService не инициализирован")
            state = .error("TransactionsService не инициализирован")
            return
        }
        do {
            let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            let endDate = Date()
            let transactions = try await transactionsService.getTransactions(from: startDate, to: endDate)
            let calendar = Calendar.current
            
            let grouped = Dictionary(grouping: transactions) {
                calendar.startOfDay(for: $0.transactionDate)
            }
            
            var currentDate = calendar.startOfDay(for: startDate)
            let end = calendar.startOfDay(for: endDate)
            var dailyBalance: [DailyBalance] = []
            
            while currentDate <= end {
                let transactions = grouped[currentDate] ?? []
                
                let balance = transactions.reduce(Decimal(0)) { sum, transaction in
                    switch transaction.category.direction {
                    case .income:
                        return sum + transaction.amount
                    case .outcome:
                        return sum - transaction.amount
                    }
                }
                
                dailyBalance.append(
                    DailyBalance(date: currentDate, balance: (balance as NSDecimalNumber).doubleValue)
                )
                
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
            self.dailyBalance = dailyBalance
            state = .data
        } catch {
            print("Ошибка при загрузке истории баланса: \(error)")
            state = .error(error.localizedDescription)
        }
    }
    
    func updateAccount(balance: Decimal, currency: Currency) async {
        guard var account,
              let bankAccountService else {
            print("BankAccountService не инициализирован")
            state = .error("Сервис банковского аккаунта не инициализирован")
            return
        }
        account = BankAccount(id: account.id, name: account.name, balance: balance, currency: currency)
        do {
            let result = try await bankAccountService.updateAccount(account)
            self.account = result
        } catch {
            print("Ошибка при обновлении аккаунта: \(error)")
        }
    }
}
