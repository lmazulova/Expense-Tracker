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
    var currency: Currency = .rub {
        didSet {
            bankAccountManager.updateCurrency(currency)
        }
    }
    var balance: Decimal = 0 {
        didSet {
            bankAccountManager.updateBalance(balance)
        }
    }
    var isSpoilerOn: Bool = false
    var balanceText: String = ""
    
    private let formatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " " // пробел между разрядами
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        return formatter
    }()
    
    func toggleEditMode() {
        withAnimation {
            isEditMode.toggle()
            isSpoilerOn = false
            if !isEditMode {
                // При выходе из режима редактирования обновляем текст
//                balanceText = "\(balance)"
//                balance = Dec
            }
        }
    }
    
    func requestForUpdate() async {
        await bankAccountManager.requestForUpdate()
    }
}
