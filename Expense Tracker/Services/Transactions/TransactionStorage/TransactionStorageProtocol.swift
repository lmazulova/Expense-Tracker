import Foundation

protocol TransactionStorageProtocol {
    func getTransactions(from: Date, to: Date) async throws -> [Transaction]
    func create(_ transaction: Transaction) async throws
    func update(_ transaction: Transaction) async throws
    func delete(id: Int) async throws
    
    // Helper methods for finding entities
    func findAccountEntity(by id: Int) async throws -> BankAccountEntity?
    func findCategoryEntity(by id: Int) async throws -> CategoryEntity?
}
