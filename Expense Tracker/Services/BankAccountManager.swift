//
//  BankAccountManager.swift
//  Expense Tracker
//
//  Created by user on 26.06.2025.
//

import Foundation

protocol BankAccountStorage {
    func saveAccount(_ account: BankAccountShort)
    func loadAccount() -> BankAccountShort?
}

@Observable
final class BankAccountManager {
    private let key = "bankAccount"
    private let transactionService: TransactionsService
    private let storage: BankAccountStorage
    
    private(set) var account: BankAccountShort
    
    init(transactionService: TransactionsService = TransactionsService(), storage: BankAccountStorage = UserDefaultsBankAccountStorage()) {
        self.transactionService = transactionService
        self.storage = storage
        
        if let loadedAccount = storage.loadAccount() {
            self.account = loadedAccount
        } else {
            let newAccount = BankAccountShort(
                id: 1,
                name: "Основной счет",
                balance: transactionService.allTransactions.reduce(Decimal(0)) { $0 + $1.amount },
                currency: .rub
            )
            storage.saveAccount(newAccount)
            self.account = newAccount
        }
    }
    
    func updateCurrency(_ newCurrency: Currency) {
        let newAccount = BankAccountShort(
            id: account.id,
            name: account.name,
            balance: account.balance,
            currency: newCurrency
        )
        account = newAccount
        storage.saveAccount(account)
    }
    
    func updateBalance(_ newBalance: Decimal) {
        let newAccount = BankAccountShort(
            id: account.id,
            name: account.name,
            balance: newBalance,
            currency: account.currency
        )
        account = newAccount
        storage.saveAccount(account)
    }
}
