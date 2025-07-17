//
//  UserDefaultsBankAccountStorage.swift
//  Expense Tracker
//
//  Created by user on 26.06.2025.
//

import Foundation

final class UserDefaultsBankAccountStorage: BankAccountStorage {
    private let key = "bankAccount"
    
    func saveAccount(_ account: BankAccount) {
        do {
            let data = try JSONEncoder().encode(account)
            UserDefaults.standard.set(data, forKey: key)
        }
        catch {
            print("some error")
        }
    }
    
    func loadAccount() -> BankAccount? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode(BankAccount.self, from: data)
    }
}

