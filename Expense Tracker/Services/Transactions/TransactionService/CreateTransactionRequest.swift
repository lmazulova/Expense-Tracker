//
//  CreateTransactionRequest.swift
//  Expense Tracker
//
//  Created by user on 18.07.2025.
//

import SwiftUI

struct CreateTransactionRequest: NetworkRequest {
    typealias Response = Transaction
    
    var categoryId: Int
    var accountId: Int
    var amount: String
    var transactionDate: Date
    var comment: String?

    init(categoryId: Int, accountId: Int, amount: String, transactionDate: Date, comment: String? = nil) {
        self.categoryId = categoryId
        self.accountId = accountId
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
    }
    
    var path: String { "/transactions" }
    var method: String { "POST" }
    var headers: [String : String] { [:] }
    var queryItems: [URLQueryItem] { [] }
    var body: Data? {
        let body = CreateUpdateTransactionBody(
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment
        )
        return try? JSONEncoder().encode(body)
    }
}

