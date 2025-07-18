import Foundation

@Observable
final class TransactionsService {
    static let shared: TransactionsService = TransactionsService()
    
    private let networkClient: NetworkClient
    
    private init(networkClient: NetworkClient = NetworkClient()) {
        self.networkClient = networkClient
        Task {
            do {
                let account = try await networkClient.send(GetAccountRequest()).first
                self.accountId = account?.id ?? 0
                self.currency = account?.currency ?? .rub
            } catch {
                print("Не удалось загрузить аккаунт - \(error)")
            }
        }
    }
    
    private(set) var allTransactions: Set<Transaction> = []
    private var accountId: Int = 0
    var currency: Currency = .rub
    
    func getTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        try await networkClient.send(GetTransactionRequest(accountId: accountId, startDate: startDate, endDate: endDate))
    }
    
    func createTransaction(categoryId: Int, amount: String, transactionDate: Date, comment: String?) async throws {
        _ = try await networkClient.send(
            CreateTransactionRequest(
                categoryId: categoryId,
                accountId: accountId,
                amount: amount,
                transactionDate: transactionDate,
                comment: comment
            )
        )
    }
    
    func editTransaction(transactionId: Int, categoryId: Int, amount: String, transactionDate: Date, comment: String?) async throws {
        _ = try await networkClient.send(UpdateTransactionRequest(
            transactionId: transactionId,
            categoryId: categoryId,
            accountId: accountId,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment
        ))
    }
    
    func deleteTransaction(byId id: Int) async throws {
        _ = try await networkClient.send(DeleteTransactionRequest(id: id))
    }
}
