import Foundation
import SwiftUI

@Observable
final class CategoriesService {
    private let networkClient: NetworkClient
    private let localStorage: CategoriesStorageProtocol
    weak var appMode: AppMode?
    
    init(networkClient: NetworkClient = NetworkClient(), localStorage: CategoriesStorageProtocol) {
        self.networkClient = networkClient
        self.localStorage = localStorage
    }
    
    func categories() async throws -> [Category] {
        do {
            let categories = try await networkClient.send(GetCategoriesRequest())
            try await localStorage.save(categories)
            await MainActor.run {
                self.appMode?.isOffline = false
            }
            return categories
        } catch let error as NetworkError {
            if case .noInternet = error {
                await MainActor.run {
                    self.appMode?.isOffline = true
                }
                return try await localStorage.getAllCategories()
            }
            throw error
        }
    }
    
    func categories(with direction: Direction) async throws -> [Category] {
        do {
            let categories = try await networkClient.send(GetCategoriesWithTypeRequest(type: direction == .income))
            await MainActor.run {
                self.appMode?.isOffline = false
            }
            return categories
        } catch let error as NetworkError {
            if case .noInternet = error {
                await MainActor.run {
                    self.appMode?.isOffline = true
                }
                return try await localStorage.getCategories(by: direction)
            }
            throw error
        }
    }
}
