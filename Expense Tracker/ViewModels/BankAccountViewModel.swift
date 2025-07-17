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
    let bankAccountService: BankAccountService
    var isEditMode: Bool = false
    var bankAccountManager: BankAccountManager = BankAccountManager()
    var currency: Currency = .rub {
        didSet {
            bankAccountManager.updateCurrency(currency)
        }
    }
    private(set) var balance: Decimal = 0 {
        didSet {
            bankAccountManager.updateBalance(balance)
        }
    }
    
    init(bankAccountService: BankAccountService = BankAccountService()) {
        self.bankAccountService = bankAccountService
    }
    
    func toggleEditMode() {
        withAnimation {
            isEditMode.toggle()
            if !isEditMode {
                // При выходе из режима редактирования обновляем текст
                
            } else {
//                initialBalanceText = balanceText
            }
        }
    }
    func loadAccount() async {
        do {
            let account = try await bankAccountService.currentAccount()
            self.balance = account.balance
            self.currency = account.currency
        } catch {
            print("Ошибка при загрузке акаунта: \(error)")
        }
    }
    
    func requestForUpdate() async {
        await bankAccountManager.requestForUpdate()
    }
    
    func setBalance(balance: Decimal) {
        self.balance = balance
    }
}
