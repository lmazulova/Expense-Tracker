import Foundation

import SwiftData

final class TransactionStorage: TransactionStorageProtocol {
    private let container: ModelContainer
    private let context: ModelContext
    
    init() {
        self.container = try! ModelContainer(for: TransactionEntity.self, BankAccountEntity.self, CategoryEntity.self)
        self.context = ModelContext(container)
    }
    
    func getTransactions(from: Date, to: Date) async throws -> [Transaction] {
        var predicate: Predicate<TransactionEntity> = #Predicate { _ in true }
        predicate = #Predicate {
            $0.transactionDate >= from && $0.transactionDate <= to
        }
        let descriptor = FetchDescriptor<TransactionEntity>(predicate: predicate)
        return try context.fetch(descriptor).map { $0.toModel() }
    }
    
    func fetchAll() async throws -> [Transaction] {
        let descriptor = FetchDescriptor<TransactionEntity>()
        return try context.fetch(descriptor).map { $0.toModel() }
    }

    func create(_ transaction: Transaction) async throws {
        context.insert(TransactionEntity(model: transaction))
        try context.save()
    }

    func update(_ transaction: Transaction) async throws {
        let id = transaction.id
        let fetch = FetchDescriptor<TransactionEntity>(predicate: #Predicate { $0.id == id })
        if let existing = try context.fetch(fetch).first {
            existing.account = BankAccountEntity(model: transaction.account)
            existing.category = CategoryEntity(model: transaction.category)
            existing.amount = transaction.amount
            existing.transactionDate = transaction.transactionDate
            existing.comment = transaction.comment
            existing.createdAt = transaction.createdAt
            existing.updatedAt = transaction.updatedAt
            try context.save()
        }
    }

    func delete(id: Int) async throws {
        let fetch = FetchDescriptor<TransactionEntity>(predicate: #Predicate { $0.id == id })
        if let transaction = try context.fetch(fetch).first {
            context.delete(transaction)
            try context.save()
        }
    }
}
