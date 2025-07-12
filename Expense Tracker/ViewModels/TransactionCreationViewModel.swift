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
    
    init(direction: Direction, selectedTransaction: Transaction? = nil) {
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
        Task {
            do {
                self.categories = try await CategoriesService().categories(with: direction)
            } catch {
            }
        }
    }
    
    private var transaction: Transaction?
    
    private let transactionService: TransactionsService = TransactionsService.shared
    
    func editTransaction() async {
            if let id = selectedTransaction?.id,
               let category = selectedCategory,
               let amount = amountText.decimalFromLocalizedString(),
               let createdAt = selectedTransaction?.createdAt {
                
                let transaction = Transaction(
                    id: id,
                    account: BankAccountManager().account,
                    category: category,
                    amount: amount,
                    transactionDate: selectedDate,
                    comment: comment.isEmpty ? nil : comment,
                    createdAt: createdAt,
                    updatedAt: Date()
                )
                
                do {
                    try await transactionService.editTransaction(transaction)
                } catch {
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
        if let category = selectedCategory,
           let amount = amountText.decimalFromLocalizedString() {
            
            let transaction = Transaction(
                id: Int.random(in: 1...100_000),
                account: BankAccountManager().account,
                category: category,
                amount: amount,
                transactionDate: selectedDate,
                comment: comment.isEmpty ? nil : comment,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            do {
                try await transactionService.createTransaction(transaction)
            } catch {
            }
        }
    }
}
