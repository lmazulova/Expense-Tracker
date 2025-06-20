import Foundation

enum Currency: String {
    case rub = "₽"
    case usd = "$"
    case eur = "€"
}

struct BankAccount {
    let id: Int
    let userId: Int
    let name: String
    let balance: Decimal
    let currency: Currency
    let createdAt: Date
    let updatedAt: Date
}

struct BankAccountShort: Hashable {
    let id: Int
    let name: String
    let balance: Decimal
    let currency: Currency
}
