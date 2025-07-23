import Foundation
import Foundation

@Observable
final class TransactionsService {
    private let networkClient: NetworkClient
    private let localStorage: TransactionStorageProtocol
    private(set) var allTransactions: Set<Transaction> = []
    private var accountId: Int?
    var currency: Currency?
    
    init(
        networkClient: NetworkClient = NetworkClient(),
        localStorage: TransactionStorageProtocol,
    ) {
        self.networkClient = networkClient
        self.localStorage = localStorage
    }
    
    func getTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        do {
            if accountId == nil || currency == nil {
                do {
                    let account = try await networkClient.send(GetAccountRequest()).first
                    self.accountId = account?.id
                    self.currency = account?.currency
                } catch {
                    print ("Не удалось загрузить аккаунт")
                    throw error
                }
            }
            guard let accountId else {
                print ("Не удалось загрузить аккаунт")
                throw NetworkError.invalidURL
            }
            let transactions = try await networkClient.send(GetTransactionRequest(accountId: accountId, startDate: startDate, endDate: endDate))
            return transactions
        }
        catch let error as NetworkError {
           if case .noInternet = error  {
               return try await localStorage.getTransactions(from: startDate, to: endDate)
           }
        throw error
       }
    }
    
    func createTransaction(categoryId: Int, amount: String, transactionDate: Date, comment: String?) async throws {
        do {
            guard let accountId else {
                throw NetworkError.invalidURL
            }
            let response = try await networkClient.send(
                CreateTransactionRequest(
                    categoryId: categoryId,
                    accountId: accountId,
                    amount: amount,
                    transactionDate: transactionDate,
                    comment: comment
                )
            )
            try await localStorage.create(response)
        } catch {
            //MARK: - здесь нужно сделать сохранение в локальное хранилище
        }
    }
    
    func editTransaction(transactionId: Int, categoryId: Int, amount: String, transactionDate: Date, comment: String?) async throws {
        do {
            guard let accountId else {
                throw NetworkError.invalidURL
            }
            let response = try await networkClient.send(UpdateTransactionRequest(
                transactionId: transactionId,
                categoryId: categoryId,
                accountId: accountId,
                amount: amount,
                transactionDate: transactionDate,
                comment: comment
            ))
            try await localStorage.update(response)
        } catch {
            //MARK: - здесь нужно сделать сохранение в локальное хранилище
        }
    }
    
    func deleteTransaction(byId id: Int) async throws {
        do {
            _ = try await networkClient.send(DeleteTransactionRequest(id: id))
        } catch {
            print("Не удалось удалить транзакцию с сервера: \(error)")
        }
        try await localStorage.delete(id: id)
    }
}
