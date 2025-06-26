import Foundation

enum Currency: String, Codable{
    case rub = "₽"
    case usd = "$"
    case eur = "€"
}

struct BankAccount: Codable {
    let id: Int
    let userId: Int
    let name: String
    let balance: Decimal
    let currency: Currency
    let createdAt: Date
    let updatedAt: Date
}

struct BankAccountShort: Hashable, Codable {
    let id: Int
    let name: String
    let balance: Decimal
    let currency: Currency
}
