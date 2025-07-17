import Foundation

actor CategoriesService {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = NetworkClient()) {
        self.networkClient = networkClient
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
