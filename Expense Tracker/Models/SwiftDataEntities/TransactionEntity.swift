import Foundation
import SwiftData

@Model
final class TransactionEntity {
    @Attribute(.unique) var id: Int
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    var createdAt: Date
    var updatedAt: Date
    
    // Связи
    @Relationship(deleteRule: .cascade) var account: BankAccountEntity
    @Relationship(deleteRule: .cascade) var category: CategoryEntity
    
    init(
        id: Int,
        amount: Decimal,
        transactionDate: Date,
        comment: String?,
        createdAt: Date,
        updatedAt: Date,
        account: BankAccountEntity,
        category: CategoryEntity
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
    
    convenience init(model: Transaction) {
        self.init(
            id: model.id,
            amount: model.amount,
            transactionDate: model.transactionDate,
            comment: model.comment,
            createdAt: model.createdAt,
            updatedAt: model.updatedAt,
            account: BankAccountEntity(model: model.account),
            category: CategoryEntity(model: model.category)
        )
    }
}

//MARK: - Преобразование и entity в model
extension TransactionEntity {
    func toModel() -> Transaction {
        Transaction(
            id: id,
            account: account.toModel(),
            category: category.toModel(),
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
