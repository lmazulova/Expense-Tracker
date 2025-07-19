//
//  GetCategoriesWithTypeRequest.swift
//  Expense Tracker
//
//  Created by user on 17.07.2025.
//

import Foundation

struct GetCategoriesWithTypeRequest: NetworkRequest {
    typealias Response = [Category]
    
    var type: Bool
    
    init(type: Bool) {
        self.type = type
    }
    
    var path: String {"/categories/type/\(type)"}
    var method: String { "GET" }
    var headers: [String : String] { [:] }
    var queryItems: [URLQueryItem] { [] }
    var body: Data? { nil }
}
