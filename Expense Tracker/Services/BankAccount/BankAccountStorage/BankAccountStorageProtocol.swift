import Foundation

protocol BankAccountStorageProtocol {
    func getAccount() async throws -> BankAccount
    func updateAccount(amount: Decimal, currency: Currency) async throws
    func saveAccount(account: BankAccount) async throws
    func getCurrentAccountId() async throws -> Int
}
