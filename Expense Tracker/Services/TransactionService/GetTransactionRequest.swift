//
//  GetTransactionRequest.swift
//  Expense Tracker
//
//  Created by user on 15.07.2025.
//

import Foundation
import SwiftUI

struct GetTransactionRequest: NetworkRequest {
    typealias Response = [Transaction]
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var accountId: Int
    var startDate: String
    var endDate: String
    
    init(accountId: Int, startDate: Date, endDate: Date) {
        self.accountId = accountId
        self.startDate = formatter.string(from: startDate)
        self.endDate = formatter.string(from: endDate)
    }
    
    var path: String { "/transactions/account/\(accountId)/period" }
    var method: String { "GET" }
    var headers: [String : String] { [:] }
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "startDate", value: startDate),
            URLQueryItem(name: "endDate", value: endDate)
        ]
    }
    var body: Data? { nil }
}
