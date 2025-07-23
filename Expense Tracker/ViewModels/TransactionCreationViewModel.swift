//
//  TransactionCreationViewModel.swift
//  Expense Tracker
//
//  Created by user on 12.07.2025.
//

import SwiftUI

@MainActor
@Observable
final class TransactionCreationViewModel {
    let direction: Direction
    var selectedTransaction: Transaction?
    var categories: [Category] = []
    var selectedCategory: Category?
    var selectedDate: Date = Date()
    var selectedTime: Date = Date()
    var amountText: String = ""
    var comment: String = ""
    var isEditMode: Bool = false
    var currency: Currency = .rub
    var state: LoadingState = .loading
    private var transaction: Transaction?
    private let transactionService: TransactionsService?
    private let categoriesService: CategoriesService?
    
    var isChoseCategoryPresented: Bool = false
    
    init(
        direction: Direction,
        selectedTransaction: Transaction? = nil,
        transactionService: TransactionsService?,
        categoriesService: CategoriesService?
    ) {
        self.transactionService = transactionService
        self.categoriesService = categoriesService
        self.direction = direction
        self.selectedTransaction = selectedTransaction
        if selectedTransaction != nil {
            self.isEditMode = true
        }
        if let transaction = selectedTransaction {
            self.selectedCategory = transaction.category
            self.selectedDate = transaction.transactionDate
            self.selectedTime = transaction.transactionDate
            self.amountText = String(describing: transaction.amount)
            self.comment = transaction.comment ?? ""
            self.currency = transaction.account.currency
        }
    }
    
    func editTransaction() async {
        state = .loading
        guard let transactionService else {
            print("TransactionService не инициализирован")
            return
        }
        if let id = selectedTransaction?.id,
           let categoryId = selectedCategory?.id {
            do {
                try await transactionService.editTransaction(
                    transactionId: id,
                    categoryId: categoryId,
                    amount: amountText,
                    transactionDate: selectedTime,
                    comment: comment.isEmpty ? "" : comment
                )
                state = .data
            } catch {
                print("Ошибка изменения транзакции: - \(error)")
                state = .error(error.localizedDescription)
            }
        }
    }
    
    func deleteTransaction() async {
        guard let transactionService else {
            print("TransactionService не инициализирован")
            return
        }
        if let id = selectedTransaction?.id {
            state = .loading
            do {
                try await transactionService.deleteTransaction(byId: id)
                state = .data
            } catch {
                print("Ошибка удаления транзакции")
                state = .error(error.localizedDescription)
            }
        }
    }
    
    func createTransaction() async {
        guard let transactionService else {
            print("TransactionService не инициализирован")
            return
        }
        if let categoryId = selectedCategory?.id {
            state = .loading
            do {
                try await transactionService.createTransaction(
                    categoryId: categoryId,
                    amount: amountText,
                    transactionDate: selectedTime,
                    comment: comment.isEmpty ? "" : comment,
                )
                state = .data
            } catch {
                print("Error creating transaction: \(error)")
                state = .error(error.localizedDescription)
            }
        }
    }
    
    func loadCategories() async {
        guard let categoriesService else {
            print("CategoriesService не инициализирован")
            return
        }
        state = .loading
        do {
            self.categories = try await categoriesService.categories(with: direction)
            state = .data
        } catch {
            print("Ошибка загрузки категорий")
            state = .error(error.localizedDescription)
        }
    }
}
