//
//  GetTransactionRequest.swift
//  Expense Tracker
//
//  Created by user on 15.07.2025.
//

import Foundation

struct GetTransactionRequest: NetworkRequest {
    typealias Response = [Transaction]
    
    var path: String { "/transactions/account/102/period" }
    var method: String { "GET" }
    var headers: [String : String]
    var queryItems: [URLQueryItem]
    var body: Data?
}
