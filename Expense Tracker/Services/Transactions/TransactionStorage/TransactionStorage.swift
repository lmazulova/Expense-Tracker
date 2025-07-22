import Foundation

import SwiftData

@MainActor
final class TransactionStorage: TransactionStorageProtocol {
    private let container: ModelContainer
    private let context: ModelContext
    
    init() {
        self.container = try! ModelContainer(for: TransactionModel.self, BankAccountModel.self, CategoryModel.self)
        self.context = ModelContext(container)
    }
    
    func getTransactions(from: Date, to: Date) async throws -> [Transaction] {
        var predicate: Predicate<TransactionModel> = #Predicate { _ in true }
        predicate = #Predicate {
            $0.transactionDate >= from && $0.transactionDate <= to
        }
        let descriptor = FetchDescriptor<TransactionModel>(predicate: predicate)
        return try context.fetch(descriptor).map { $0.toDTO() }
    }
    
    func create(_ transaction: Transaction) async throws {
        let account = findOrCreateAccount(from: transaction.account)
        let category = findOrCreateCategory(from: transaction.category)
        
        let transaction = TransactionModel(
            id: transaction.id,
            amount: transaction.amount,
            transactionDate: transaction.transactionDate,
            comment: transaction.comment,
            createdAt: transaction.createdAt,
            updatedAt: transaction.updatedAt,
            account: account,
            category: category
        )
        
        context.insert(transaction)
        try context.save()
    }

    func update(_ transaction: Transaction) async throws {
        let id = transaction.id
        let fetch = FetchDescriptor<TransactionModel>(predicate: #Predicate { $0.id == id })
        if let existing = try context.fetch(fetch).first {
            existing.account = BankAccountModel(from: transaction.account)
            existing.category = CategoryModel(from: transaction.category)
            existing.amount = transaction.amount
            existing.transactionDate = transaction.transactionDate
            existing.comment = transaction.comment
            existing.createdAt = transaction.createdAt
            existing.updatedAt = transaction.updatedAt
            try context.save()
        }
    }

    func delete(id: Int) async throws {
        let fetch = FetchDescriptor<TransactionModel>(predicate: #Predicate { $0.id == id })
        if let transaction = try context.fetch(fetch).first {
            context.delete(transaction)
            try context.save()
        }
    }
    
    // MARK: - Helper methods for finding entities by ID
    func findOrCreateAccount(from dto: BankAccount) -> BankAccountModel {
        let descriptor = FetchDescriptor<BankAccountModel>(predicate: #Predicate { $0.id == dto.id })
        if let existing = try? context.fetch(descriptor).first {
            return existing
        } else {
            let account = BankAccountModel(from: dto)
            context.insert(account)
            return account
        }
    }
    
    func findOrCreateCategory(from dto: Category) -> CategoryModel {
        let descriptor = FetchDescriptor<CategoryModel>(predicate: #Predicate { $0.id == dto.id })
        if let existing = try? context.fetch(descriptor).first {
            return existing
        } else {
            let category = CategoryModel(from: dto)
            context.insert(category)
            return category
        }
    }
}
