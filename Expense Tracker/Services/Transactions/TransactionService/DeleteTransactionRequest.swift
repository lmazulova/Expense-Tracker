//
//  DeleteTransactionRequest.swift
//  Expense Tracker
//
//  Created by user on 15.07.2025.
//

import Foundation

struct DeleteTransactionRequest: NetworkRequest {
    typealias Response = EmptyResponse
    var id: Int
    
    init(id: Int) {
        self.id = id
    }
    
    var path: String { "/transactions/\(id)" }
    var method: String { "DELETE" }
    var headers: [String : String] { [:] }
    var queryItems: [URLQueryItem] { [] }
    var body: Data? { nil }
}
