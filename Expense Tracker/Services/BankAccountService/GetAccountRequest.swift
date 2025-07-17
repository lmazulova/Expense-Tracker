//
//  GetAccountRequest.swift
//  Expense Tracker
//
//  Created by user on 15.07.2025.
//

import Foundation

struct GetAccountRequest: NetworkRequest {
    typealias Response = BankAccount
    
    var path: String {"/accounts"}
    var method: String {"GET"}
    var headers: [String : String] { [:] }
    var queryItems: [URLQueryItem] { [] }
    var body: Data? { nil }
}
