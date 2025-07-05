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
    var currency: Currency = .rub
    var balance: Decimal = 0
    var isSpoilerOn: Bool = false
    var balanceText: String = ""
}
