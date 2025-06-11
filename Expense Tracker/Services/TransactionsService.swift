import Foundation

final class TransactionsService {
    private var allTransactions: Set<Transaction> = [
        Transaction(
            id: 1,
            accountId: 100,
            categoryId: 5,
            amount: Decimal(string: "1234.56")!,
            transactionDate: ISO8601DateFormatter().date(from: "2025-06-10T12:00:00Z")!,
            comment: "Обед с командой",
            createdAt: ISO8601DateFormatter().date(from: "2025-06-10T12:05:00Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-10T12:10:00Z")!
        ),
        Transaction(
            id: 2,
            accountId: 100,
            categoryId: 2,
            amount: Decimal(string: "4999.00")!,
            transactionDate: ISO8601DateFormatter().date(from: "2025-06-09T09:30:00Z")!,
            comment: "Зарплата за май",
            createdAt: ISO8601DateFormatter().date(from: "2025-06-09T09:31:00Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-09T09:32:00Z")!
        ),
        Transaction(
            id: 3,
            accountId: 100,
            categoryId: 3,
            amount: Decimal(string: "199.99")!,
            transactionDate: ISO8601DateFormatter().date(from: "2025-06-08T18:45:00Z")!,
            comment: "Покупка игры в Steam",
            createdAt: ISO8601DateFormatter().date(from: "2025-06-08T18:46:00Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-08T18:46:00Z")!
        ),
        Transaction(
            id: 4,
            accountId: 100,
            categoryId: 4,
            amount: Decimal(string: "75.50")!,
            transactionDate: ISO8601DateFormatter().date(from: "2025-06-07T08:15:00Z")!,
            comment: "Такси до офиса",
            createdAt: ISO8601DateFormatter().date(from: "2025-06-07T08:16:00Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-07T08:17:00Z")!
        ),
        Transaction(
            id: 5,
            accountId: 100,
            categoryId: 6,
            amount: Decimal(string: "250.00")!,
            transactionDate: ISO8601DateFormatter().date(from: "2025-06-06T22:00:00Z")!,
            comment: nil,
            createdAt: ISO8601DateFormatter().date(from: "2025-06-06T22:01:00Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-06T22:01:00Z")!
        )
    ]
    
    func getTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        allTransactions.filter { $0.createdAt >= startDate && $0.createdAt <= endDate }
    }
    
    func createTransaction(_ transaction: Transaction) async throws {
        guard !allTransactions.contains(where: { $0.id == transaction.id }) else { return }
        allTransactions.insert(transaction)
    }
    
    func editTransaction(_ editedTransaction: Transaction) async throws {
        guard let transaction = allTransactions.first(where: { $0.id == editedTransaction.id }) else { return }
        allTransactions.remove(transaction)
        allTransactions.insert(editedTransaction)
    }
    
    func deleteTransaction(byId id: Int) async throws {
        guard let transaction = allTransactions.first(where: { $0.id == id }) else { return }
        allTransactions.remove(transaction)
    }
}
