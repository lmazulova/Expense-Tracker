import Foundation

struct BankAccount {
    let id: Int
    let userId: Int
    let name: String
    let balance: Decimal
    let currency: String
    let createdAt: Date
    let updatedAt: Date
}

struct BankAccountShort: Hashable {
    let id: Int
    let name: String
    let balance: Decimal
    let currency: String
}
