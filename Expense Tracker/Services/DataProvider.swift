import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class DataProvider {
    let container: ModelContainer
    let context: ModelContext
    
    let transactionStorage: TransactionStorage
    let categoryStorage: CategoriesStorage
    let bankAccountStorage: BankAccountStorage
    
    init() {
        self.container = try! ModelContainer(
            for: TransactionModel.self,
            BankAccountModel.self,
            CategoryModel.self
        )
        self.context = ModelContext(container)
        
        self.transactionStorage = TransactionStorage(context: context)
        self.categoryStorage = CategoriesStorage(context: context)
        self.bankAccountStorage = BankAccountStorage(context: context)
        
        Task {
            await preloadData()
        }
    }
    
    private func loadBankAccount() async throws {
        let accounts = try await NetworkClient().send(GetAccountRequest())
        guard let account = accounts.first else {
            throw NSError(domain: "NoAccounts", code: 0, userInfo: nil)
        }
        try await bankAccountStorage.saveAccount(account: account)
    }
    
    private func loadCategories() async throws {
        let categories = try await NetworkClient().send(GetCategoriesRequest())
        try await categoryStorage.save(categories)
    }
    
    private func loadTransactions(from: Date, to: Date) async throws {
        let accountId = try await bankAccountStorage.getCurrentAccountId()
        let transactions = try await NetworkClient().send(GetTransactionRequest(accountId: accountId, startDate: from, endDate: to))
        for transaction in transactions {
            try await transactionStorage.create(transaction)
        }
    }
    
    private func preloadData() async {
        // 1. Загружаем аккаунт
        do {
            try await loadBankAccount()
        } catch {
            print("[\(#function)] - Ошибка загрузки аккаунта: \(error.localizedDescription)")
        }
        // 2. Загружаем категории
        do {
            try await loadCategories()
        } catch {
            print("[\(#function)] - Ошибка загрузки категорий: \(error.localizedDescription)")
        }
        
        // 3. Загружаем транзакции за последние 2 месяца
        do {
            try await loadTransactions(
                from: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
                to: Date()
            )
        } catch {
            print("[\(#function)] - Ошибка загрузки транзакций: \(error.localizedDescription)")
        }
    }
}
