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

@Model
final class BankAccountEntity {
    @Attribute(.unique) var id: Int
    var name: String
    var balance: Decimal
    var currencyRaw: String

    init(id: Int, name: String, balance: Decimal, currencyRaw: String) {
        self.id = id
        self.name = name
        self.balance = balance
        self.currencyRaw = currencyRaw
    }

    convenience init(model: BankAccount) {
        self.init(
            id: model.id,
            name: model.name,
            balance: model.balance,
            currencyRaw: model.currency.rawValue
        )
    }
}

@Model
final class CategoryEntity {
    @Attribute(.unique) var id: Int
    var name: String
    var emoji: String
    var isIncome: Bool

    init(id: Int, name: String, emoji: String, isIncome: Bool) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.isIncome = isIncome
    }

    convenience init(model: Category) {
        self.init(
            id: model.id,
            name: model.name,
            emoji: String(model.emoji),
            isIncome: model.direction == .income
        )
    }
}

// MARK: - Entity -> Model

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

extension BankAccountEntity {
    func toModel() -> BankAccount {
        BankAccount(
            id: id,
            name: name,
            balance: balance,
            currency: Currency(rawValue: currencyRaw) ?? .rub
        )
    }
}

extension CategoryEntity {
    func toModel() -> Category {
        Category(
            id: id,
            name: name,
            emoji: emoji.first ?? " ",
            direction: isIncome ? .income : .outcome
        )
    }
} 