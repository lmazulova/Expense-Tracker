//
//  UpdateAccountRequest.swift
//  Expense Tracker
//
//  Created by user on 15.07.2025.
//

import Foundation

struct UpdateAccountRequest: NetworkRequest {
    typealias Response = BankAccount
    
    var path: String { "/accounts" }
    var method: String { "PUT" }
    var headers: [String : String]
    var queryItems: [URLQueryItem]
    var body: Data?
}
