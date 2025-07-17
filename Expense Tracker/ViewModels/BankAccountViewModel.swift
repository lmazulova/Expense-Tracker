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
    private(set) var account: BankAccount?
    
    init(bankAccountService: BankAccountService = BankAccountService()) {
        self.bankAccountService = bankAccountService
    }
    
    func toggleEditMode() {
        withAnimation {
            isEditMode.toggle()
        }
    }
    
    func loadAccount() async {
        do {
            let account = try await bankAccountService.currentAccount()
            self.account = account
        } catch {
            print("Ошибка при загрузке акаунта: \(error)")
        }
    }
    
    func updateAccount(balance: Decimal, currency: Currency) async {
        guard var account = account else { return }
        account = BankAccount(id: account.id, name: account.name, balance: balance, currency: currency)
        do {
            let result = try await bankAccountService.updateAccount(account)
            self.account = result
        } catch {
            print("Ошибка при обновлении аккаунта: \(error)")
        }
    }
}
