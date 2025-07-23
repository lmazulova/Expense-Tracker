import SwiftData
import Foundation

@MainActor
final class BankAccountStorage: BankAccountStorageProtocol {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func getAccount() async throws -> BankAccount {
        let descriptor = FetchDescriptor<BankAccountModel>()
        let accounts = try context.fetch(descriptor)
        
        guard let account = accounts.first else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Account not found"])
        }
        
        return account.toDTO()
    }
    
    func updateAccount(amount: Decimal, currency: Currency) async throws {
        let descriptor = FetchDescriptor<BankAccountModel>()
        guard let account = try context.fetch(descriptor).first else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No account to update"])
        }
        account.balance = amount
        account.currencyRaw = currency.serverCode
        
        try context.save()
    }
    
    func saveAccount(account: BankAccount) async throws {
        let id = account.id
        let descriptor = FetchDescriptor<BankAccountModel>(predicate: #Predicate { $0.id == id })
        
        if let initAccount = try context.fetch(descriptor).first {
            initAccount.name = account.name
            initAccount.balance = account.balance
            initAccount.currencyRaw = account.currency.rawValue
        } else {
            context.insert(BankAccountModel(from: account))
        }
        try context.save()
    }
    
    func getCurrentAccountId() async throws -> Int {
        let account = try await getAccount()
        return account.id
    }
}


extension BankAccountStorage: BankAccountBackupProtocol {
    func saveBackupUpdate(balance: Decimal, currency: Currency) async throws {
        let update = BankAccountBackupModel(balance: balance, currencyRaw: currency.serverCode)
        context.insert(update)
        try context.save()
    }
    
    func fetchBackupUpdate() async throws -> BankAccountBackupModel? {
        let descriptor = FetchDescriptor<BankAccountBackupModel>(
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        return try context.fetch(descriptor).first
    }
    
    func clearBackupUpdates() async throws {
        let descriptor = FetchDescriptor<BankAccountBackupModel>()
        let updates = try context.fetch(descriptor)
        for update in updates {
            context.delete(update)
        }
        try context.save()
    }
}
