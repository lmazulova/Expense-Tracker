import SwiftData
import Foundation

final class BankAccountStorage: BankAccountStorageProtocol {
    private let context: ModelContext
    private let container: ModelContainer
    
    init() {
        self.container = try! ModelContainer(for: BankAccountEntity.self)
        self.context = ModelContext(container)
    }
    
    func getAccount() async throws -> BankAccount {
        let descriptor = FetchDescriptor<BankAccountEntity>()
        let accounts = try context.fetch(descriptor)
        
        guard let account = accounts.first else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Account not found"])
        }
        
        return account.toModel()
    }
    
    func updateAccount(amount: Decimal, currency: Currency) async throws {
        let descriptor = FetchDescriptor<BankAccountEntity>()
        guard let account = try context.fetch(descriptor).first else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No account to update"])
        }
        account.balance = amount
        account.currencyRaw = currency.serverCode
        
        try context.save()
    }
    
    func saveAccount(account: BankAccount) async throws {
        let id = account.id
        let descriptor = FetchDescriptor<BankAccountEntity>(predicate: #Predicate { $0.id == id })
        
        if let initAccount = try context.fetch(descriptor).first {
            initAccount.name = account.name
            initAccount.balance = account.balance
            initAccount.currencyRaw = account.currency.rawValue
        } else {
            context.insert(BankAccountEntity(model: account))
        }
        try context.save()
    }
    
    func getCurrentAccountId() async throws -> Int {
        let account = try await getAccount()
        return account.id
    }
}
