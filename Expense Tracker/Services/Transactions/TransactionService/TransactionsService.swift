import Foundation
import Foundation

@Observable
final class TransactionsService {
    private let networkClient: NetworkClient
    private let localStorage: TransactionStorageProtocol
    private let bankAccountStorage: BankAccountStorageProtocol
    private(set) var allTransactions: Set<Transaction> = []
    private var accountId: Int?
    
    weak var appMode: AppMode?
    var currency: Currency?
    
    init(
        networkClient: NetworkClient = NetworkClient(),
        localStorage: TransactionStorageProtocol,
        bankAccountStorage: BankAccountStorageProtocol
    ) {
        self.networkClient = networkClient
        self.localStorage = localStorage
        self.bankAccountStorage = bankAccountStorage
    }
    
    func getTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        do {
            if accountId == nil || currency == nil {
                do {
                    let account = try await networkClient.send(GetAccountRequest()).first
                    self.accountId = account?.id
                    self.currency = account?.currency
                } catch {
                    print ("Не удалось загрузить аккаунт из сети")
                    do {
                        self.accountId = try await bankAccountStorage.getCurrentAccountId()
                    } catch {
                        throw error
                    }
                }
            }
            guard let accountId else {
                print ("Не удалось загрузить аккаунт")
                throw NetworkError.invalidURL
            }
            await MainActor.run {
                self.appMode?.isOffline = false
            }
            let transactions = try await networkClient.send(GetTransactionRequest(accountId: accountId, startDate: startDate, endDate: endDate))
            return transactions
        }
        catch let error as NetworkError {
           if case .noInternet = error  {
               await MainActor.run {
                   self.appMode?.isOffline = true
               }
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
            await MainActor.run {
                self.appMode?.isOffline = false
            }
            try await localStorage.create(response)
        } catch let error as NetworkError {
            if case .noInternet = error  {
                
                await MainActor.run {
                    self.appMode?.isOffline = true
                }
                guard let accountId else {
                    print("Нет доступного аккаунта для сохранения")
                    throw error
                }
                return try await localStorage.create(
                    Transaction(
                        id: TemporaryIDGenerator.generateNextID(),
                        account: BankAccount(id: accountId, name: "Основной счет", balance:  0, currency: .rub),
                        category: Category(id: categoryId, name: "Заглушка для создания транзакции", emoji: "🤷‍♂", direction: .income),
                        amount: amount.decimalFromLocalizedString() ?? 0,
                        transactionDate: transactionDate,
                        comment: comment,
                        createdAt: Date(),
                        updatedAt: Date()
                    )
                )
            }
            throw error
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
            await MainActor.run {
                self.appMode?.isOffline = false
            }
        } catch let error as NetworkError {
            if case .noInternet = error  {
                guard let accountId else {
                    print("Нет доступного аккаунта для сохранения")
                    throw error
                }
                await MainActor.run {
                    self.appMode?.isOffline = true
                }
                return try await localStorage.update(
                    Transaction(
                        id: transactionId,
                        account: BankAccount(id: accountId, name: "Основной счет", balance:  0, currency: .rub),
                        category: Category(id: categoryId, name: "Заглушка для создания транзакции", emoji: "🤷‍♂", direction: .income),
                        amount: amount.decimalFromLocalizedString() ?? 0,
                        transactionDate: transactionDate,
                        comment: comment,
                        createdAt: Date(),
                        updatedAt: Date()
                    )
                )
            }
            throw error
        }
    }
    
    func deleteTransaction(byId id: Int) async throws {
        do {
            _ = try await networkClient.send(DeleteTransactionRequest(id: id))
            try await localStorage.delete(id: id)
            await MainActor.run {
                self.appMode?.isOffline = false
            }
        } catch let error as NetworkError {
            print("Не удалось удалить транзакцию с сервера: \(error)")
            if case .noInternet = error {
                await MainActor.run {
                    self.appMode?.isOffline = true
                }
                return try await localStorage.delete(id: id)
            }
            throw error
        }
    }
}
