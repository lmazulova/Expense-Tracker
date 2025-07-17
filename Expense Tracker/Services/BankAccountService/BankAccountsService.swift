import Foundation

actor BankAccountsService {
    private var account = BankAccount(
        id: 1,
        name: "Lisa",
        balance: 143388.20,
        currency: .rub
    )
    
    func currentAccount() async throws -> BankAccount {
        account
    }
    
    func updateAccount(_ updated: BankAccount) async throws {
        self.account = updated
    }
}
