import Foundation

actor BankAccountService {
    private let networkClient: NetworkClient
    private let localStorage: BankAccountStorageProtocol
    
    init(networkClient: NetworkClient = NetworkClient(), localStorage: BankAccountStorageProtocol) {
        self.networkClient = networkClient
        self.localStorage = localStorage
    }
    
    func currentAccount() async throws -> BankAccount {
        do {
            let accounts = try await networkClient.send(GetAccountRequest())
            guard let account = accounts.first else {
                throw NSError(domain: "NoAccounts", code: 0, userInfo: nil)
            }
            try await localStorage.saveAccount(account: account)
            return account
        } catch let error as NetworkError {
            if case .noInternet = error  {
                var account = try await localStorage.getAccount()
//                let backups = try backupStorage.allBackups()
//                for backup in backups {
//                    switch backup.action {
//                    case .changeCurrency:
//                        if let newCurrency = backup.stringValue {
//                            account.currency = newCurrency
//                        }
//                    
//                    case .changeBalance:
//                        if let amount = backup.decimalValue {
//                            account.balance += amount
//                        }
//                    
//                    case .changeTransaction:
//                        if let delta = backup.decimalValue {
//                            account.balance += delta
//                        }
//                    }
//                }
                return account
            }
            throw error
        }
    }
    
    func updateAccount(_ updated: BankAccount) async throws -> BankAccount {
        do {
            let account = try await networkClient.send(UpdateAccountRequest(account: updated))
            try await localStorage.updateAccount(amount: updated.balance, currency: updated.currency)
            return account
        } catch let error as NetworkError {
            if case .noInternet = error  {
                try await localStorage.updateAccount(amount: updated.balance, currency: updated.currency)
                var account = try await localStorage.getAccount()
//                let backups = try backupStorage.allBackups()
//                for backup in backups {
//                    switch backup.action {
//                    case .changeCurrency:
//                        if let newCurrency = backup.stringValue {
//                            account.currency = newCurrency
//                        }
//                    
//                    case .changeBalance:
//                        if let amount = backup.decimalValue {
//                            account.balance += amount
//                        }
//                    
//                    case .changeTransaction:
//                        if let delta = backup.decimalValue {
//                            account.balance += delta
//                        }
//                    }
//                }
//                try backupStorage.addBalanceChange(amount: amount - account.balance)
//                try backupStorage.addChangeCurrency(newCurrency: newCurrencyCode)
                return account
            }
            throw error
        }
    }
}
