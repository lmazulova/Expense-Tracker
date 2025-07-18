import Foundation

protocol TransactionStorageProtocol {
    func getTransactions(from: Date, to: Date) async throws -> [Transaction]
    func fetchAll() async throws -> [Transaction]
    func create(_ transaction: Transaction) async throws
    func update(_ transaction: Transaction) async throws
    func delete(id: Int) async throws
}
