//
//  UpdateTransactionRequest.swift
//  Expense Tracker
//
//  Created by user on 15.07.2025.
//

import Foundation

struct UpdateTransactionRequest: NetworkRequest {
    typealias Response = Transaction
    
    var path: String { "/transactions" }
    var method: String { "PUT" }
    var headers: [String : String]
    var queryItems: [URLQueryItem]
    var body: Data?
}
