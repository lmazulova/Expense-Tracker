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
        try await networkClient.send(GetCategoriesRequest())
    }
    
    func categories(with direction: Direction) async throws -> [Category] {
        switch direction {
        case .income:
            return try await networkClient.send(GetCategoriesWithTypeRequest(type: true))
        case .outcome:
            return try await networkClient.send(GetCategoriesWithTypeRequest(type: false))
        }
    }
}
