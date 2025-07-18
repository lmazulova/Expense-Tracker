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
    
    convenience init(model: Transaction, context: ModelContext) {
        // Найти существующий аккаунт или создать новый
        let accountEntity: BankAccountEntity
        let accountId = model.account.id
        let accountDescriptor = FetchDescriptor<BankAccountEntity>(
            predicate: #Predicate<BankAccountEntity> { entity in
                entity.id == accountId
            }
        )
        
        if let existingAccount = try? context.fetch(accountDescriptor).first {
            accountEntity = existingAccount
        } else {
            accountEntity = BankAccountEntity(model: model.account)
            context.insert(accountEntity)
        }
        
        // Найти существующую категорию или создать новую
        let categoryEntity: CategoryEntity
        let categoryId = model.category.id
        let categoryDescriptor = FetchDescriptor<CategoryEntity>(
            predicate: #Predicate<CategoryEntity> { entity in
                entity.id == categoryId
            }
        )
        
        if let existingCategory = try? context.fetch(categoryDescriptor).first {
            categoryEntity = existingCategory
        } else {
            categoryEntity = CategoryEntity(model: model.category)
            context.insert(categoryEntity)
        }
        
        self.init(
            id: model.id,
            amount: model.amount,
            transactionDate: model.transactionDate,
            comment: model.comment,
            createdAt: model.createdAt,
            updatedAt: model.updatedAt,
            account: accountEntity,
            category: categoryEntity
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

