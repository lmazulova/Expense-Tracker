import Foundation
import SwiftData

@Model
final class BankAccountModel {
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
    
    convenience init(from dto: BankAccount) {
        self.init(
            id: dto.id,
            name: dto.name,
            balance: dto.balance,
            currencyRaw: dto.currency.rawValue
        )
    }
}

//MARK: - Преобразование из model в структуру
extension BankAccountModel {
    func toDTO() -> BankAccount {
        BankAccount(
            id: id,
            name: name,
            balance: balance,
            currency: Currency(rawServerCode: currencyRaw) ?? .rub
        )
    }
}
