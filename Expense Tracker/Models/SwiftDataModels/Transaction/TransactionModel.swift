import Foundation
import SwiftData

@Model
final class TransactionModel {
    @Attribute(.unique) var id: Int
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship var account: BankAccountModel
    @Relationship var category: CategoryModel
    
    init(
        id: Int,
        amount: Decimal,
        transactionDate: Date,
        comment: String?,
        createdAt: Date,
        updatedAt: Date,
        account: BankAccountModel,
        category: CategoryModel
    ) {
        self.id = id
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.account = account
        self.category = category
    }
}

//MARK: - Преобразование из model в структуру
extension TransactionModel {
    func toDTO() -> Transaction {
        Transaction(
            id: id,
            account: account.toDTO(),
            category: category.toDTO(),
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

