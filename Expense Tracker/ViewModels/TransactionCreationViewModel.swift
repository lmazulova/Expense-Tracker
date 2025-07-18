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
    
    var isChoseCategoryPresented: Bool = false
    
    init(
        direction: Direction,
        selectedTransaction: Transaction? = nil,
        transactionService: TransactionsService,
        categoriesService: CategoriesService
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
    
    private var transaction: Transaction?
    
    private let transactionService: TransactionsService
    private let categoriesService: CategoriesService
    
    func editTransaction() async {
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
                } catch {
                    print("Ошибка изменения транзакции: - \(error)")
                }
            }
    }
    
    func deleteTransaction() async {
        if let id = selectedTransaction?.id {
            do {
                try await transactionService.deleteTransaction(byId: id)
            } catch {
            }
        }
    }
    
    func createTransaction() async {
        if let categoryId = selectedCategory?.id {
            do {
                try await transactionService.createTransaction(
                    categoryId: categoryId,
                    amount: amountText,
                    transactionDate: selectedTime,
                    comment: comment.isEmpty ? "" : comment,
                )
            } catch {
                print("Error creating transaction: \(error)")
            }
        }
    }
    
    func loadCategories() async {
        do {
            self.categories = try await categoriesService.categories(with: direction)
        } catch {
            
        }
    }
}
