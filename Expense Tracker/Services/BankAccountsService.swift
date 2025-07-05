import Foundation

actor BankAccountsService {
    private var account = BankAccount(
        id: 1,
        userId: 1,
        name: "Lisa",
        balance: 143388.20,
        currency: .rub,
        createdAt: ISO8601DateFormatter().date(from: "2025-02-10T12:05:00Z")!,
        updatedAt: ISO8601DateFormatter().date(from: "2025-06-10T12:05:00Z")!
    )
    
    func currentAccount() async throws -> BankAccount {
        account
    }
    
    func updateAccount(_ updated: BankAccount) async throws {
        self.account = updated
    }
}
