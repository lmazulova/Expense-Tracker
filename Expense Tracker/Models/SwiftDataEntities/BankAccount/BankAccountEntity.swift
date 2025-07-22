import Foundation
import SwiftData

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

//MARK: - Преобразование и entity в model
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
