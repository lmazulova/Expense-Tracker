//
//  UpdateTransactionRequest.swift
//  Expense Tracker
//
//  Created by user on 15.07.2025.
//

import Foundation

struct UpdateTransactionRequest: NetworkRequest {
    typealias Response = Transaction
    
    var id: Int
    var categoryId: Int
    var accountId: Int
    var amount: String
    var transactionDate: Date
    var comment: String?

    init(transactionId: Int, categoryId: Int, accountId: Int, amount: String, transactionDate: Date, comment: String? = nil) {
        self.id = transactionId
        self.categoryId = categoryId
        self.accountId = accountId
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
    }
    
    var path: String { "/transactions/\(id)" }
    var method: String { "PUT" }
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
