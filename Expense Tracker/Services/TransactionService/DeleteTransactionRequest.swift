//
//  DeleteTransactionRequest.swift
//  Expense Tracker
//
//  Created by user on 15.07.2025.
//

import Foundation

struct DeleteTransactionRequest: NetworkRequest {
    typealias Response = Transaction
    
    var path: String
    var method: String { "DELETE" }
    var headers: [String : String]
    var queryItems: [URLQueryItem]
    var body: Data?
}
