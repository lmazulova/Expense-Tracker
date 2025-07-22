//
//  UpdateAccountRequest.swift
//  Expense Tracker
//
//  Created by user on 15.07.2025.
//

import Foundation

struct UpdateAccountRequest: NetworkRequest {
    typealias Response = BankAccount
    var account: BankAccount
    
    init(account: BankAccount) {
        self.account = account
    }
    
    var path: String { "/accounts/\(account.id)" }
    var method: String { "PUT" }
    var headers: [String : String] { [:] }
    var queryItems: [URLQueryItem] { [] }
    var body: Data? {
        let updateBody = UpdateAccountBody(
            name: account.name,
            balance: String(describing: account.balance),
            currency: account.currency.serverCode
        )
        return try? JSONEncoder().encode(updateBody)
    }
}

struct UpdateAccountBody: Encodable {
    let name: String
    let balance: String
    let currency: String
}
