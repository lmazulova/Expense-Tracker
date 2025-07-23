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
    var state: LoadingState = .loading
    var isEditMode: Bool = false
    private(set) var account: BankAccount?
    
    init(bankAccountService: BankAccountService? = nil) {
        self.bankAccountService = bankAccountService
    }
    
    func toggleEditMode() {
        withAnimation {
            isEditMode.toggle()
        }
    }
    
    func loadAccount() async {
        state = .loading
        guard let bankAccountService = bankAccountService else {
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
