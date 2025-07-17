//
//  NetworkRequest.swift
//  Expense Tracker
//
//  Created by user on 15.07.2025.
//

import Foundation

protocol NetworkRequest {
    associatedtype Response: Decodable
    
    var path: String { get }
    var method: String { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem] { get }
    var body: Data? { get }
}
