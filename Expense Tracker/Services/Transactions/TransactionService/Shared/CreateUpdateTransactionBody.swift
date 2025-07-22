//
//  CreateTransactionBody.swift
//  Expense Tracker
//
//  Created by user on 18.07.2025.
//

import SwiftUI

struct CreateUpdateTransactionBody: Encodable {
    var accountId: Int
    var categoryId: Int
    var amount: String
    var transactionDate: String
    var comment: String?
    
    init(accountId: Int, categoryId: Int, amount: String, transactionDate: Date, comment: String?) {
        self.accountId = accountId
        self.categoryId = categoryId
        self.amount = amount
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        self.transactionDate = formatter.string(from: transactionDate)
        self.comment = comment
    }
    
    enum CodingKeys: String, CodingKey {
        case accountId, categoryId, amount, transactionDate, comment
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accountId, forKey: .accountId)
        try container.encode(categoryId, forKey: .categoryId)
        try container.encode(amount, forKey: .amount)
        try container.encode(transactionDate, forKey: .transactionDate)
        try container.encodeIfPresent(comment, forKey: .comment)
    }
}
