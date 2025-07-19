//
//  CategoriesStorageProtocol.swift
//  Expense Tracker
//
//  Created by user on 18.07.2025.
//

import Foundation

protocol CategoriesStorageProtocol {
    func getAllCategories() async throws -> [Category]
    func getCategories(by direction: Direction) async throws -> [Category]
    func save(_ categories: [Category]) async throws
}
