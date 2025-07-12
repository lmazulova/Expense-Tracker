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
    var isEditMode: Bool = false
    var bankAccountManager: BankAccountManager = BankAccountManager()
    var currency: Currency = BankAccountManager().account.currency {
        didSet {
            bankAccountManager.updateCurrency(currency)
        }
    }
    private(set) var balance: Decimal = BankAccountManager().account.balance {
        didSet {
            bankAccountManager.updateBalance(balance)
        }
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
    
    func requestForUpdate() async {
        await bankAccountManager.requestForUpdate()
    }
    
    func setBalance(balance: Decimal) {
        self.balance = balance
    }
}
