import Foundation

enum Currency: String, Codable, CaseIterable {
    case rub = "₽"
    case usd = "$"
    case eur = "€"
}

struct BankAccount: Codable, Hashable {
    let id: Int
    let name: String
    let balance: Decimal
    let currency: Currency
}
