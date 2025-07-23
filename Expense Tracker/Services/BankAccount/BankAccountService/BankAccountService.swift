import Foundation

actor BankAccountService {
    private let networkClient: NetworkClient
    private let localStorage: BankAccountStorageProtocol & BankAccountBackupProtocol
    
    init(networkClient: NetworkClient = NetworkClient(), localStorage: BankAccountStorageProtocol & BankAccountBackupProtocol) {
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
                let account = try await localStorage.getAccount()
                return account
            }
            throw error
        }
    }
    
    func updateAccount(_ updated: BankAccount) async throws -> BankAccount {
        do {
            let account = try await networkClient.send(UpdateAccountRequest(account: updated))
            try await localStorage.updateAccount(amount: updated.balance, currency: updated.currency)
            try await localStorage.saveBackupUpdate(balance: updated.balance, currency: updated.currency)
            return account
        } catch let error as NetworkError {
            if case .noInternet = error  {
                try await localStorage.updateAccount(amount: updated.balance, currency: updated.currency)
                try await localStorage.saveBackupUpdate(balance: updated.balance, currency: updated.currency)
                let account = try await localStorage.getAccount()
                return account
            }
            throw error
        }
    }
}

extension BankAccountService: BackupSyncProtocol {
    func syncBackupUpdates() async throws {
        guard let pending = try await localStorage.fetchBackupUpdate() else { return }
        
        let localAccount = try await localStorage.getAccount()
        
        let accountToUpdate = BankAccount(
            id: localAccount.id,
            name: localAccount.name,
            balance: pending.balance,
            currency: Currency(rawValue: pending.currencyRaw) ?? localAccount.currency
        )
        
        _ = try await updateAccount(accountToUpdate)
        try await localStorage.clearBackupUpdates()
    }
}
