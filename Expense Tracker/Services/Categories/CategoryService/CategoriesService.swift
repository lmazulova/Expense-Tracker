import Foundation
import SwiftUI

@Observable
final class CategoriesService {
    private let networkClient: NetworkClient
    private let localStorage: CategoriesStorageProtocol
    
    init(networkClient: NetworkClient = NetworkClient(), localStorage: CategoriesStorageProtocol) {
        self.networkClient = networkClient
        self.localStorage = localStorage
    }
    
    func categories() async throws -> [Category] {
        do {
            let categories = try await networkClient.send(GetCategoriesRequest())
            try await localStorage.save(categories)
            return categories
        } catch let error as NetworkError {
            if case .noInternet = error {
                return try await localStorage.getAllCategories()
            }
            throw error
        }
    }
    
    func categories(with direction: Direction) async throws -> [Category] {
        do {
            switch direction {
            case .income:
                return try await networkClient.send(GetCategoriesWithTypeRequest(type: true))
            case .outcome:
                return try await networkClient.send(GetCategoriesWithTypeRequest(type: false))
            }
        } catch let error as NetworkError {
            if case .noInternet = error {
                return try await localStorage.getCategories(by: direction)
            }
            throw error
        }
    }
}
