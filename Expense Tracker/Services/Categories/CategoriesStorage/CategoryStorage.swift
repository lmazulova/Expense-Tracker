import SwiftData
import Foundation

@MainActor
final class CategoriesStorage: CategoriesStorageProtocol {
    private let context: ModelContext
    private let container: ModelContainer
    
    init() {
        self.container = try! ModelContainer(for: CategoryEntity.self)
        self.context = ModelContext(container)
    }
    
    func getAllCategories() async throws -> [Category] {
        let descriptor = FetchDescriptor<CategoryEntity>()
        let categories = try context.fetch(descriptor)
        return categories.map { $0.toModel() }
    }
    
    func getCategories(by direction: Direction) async throws -> [Category] {
        let isIncome = direction == .income
        let predicate = #Predicate<CategoryEntity> { $0.isIncome == isIncome }
        let descriptor = FetchDescriptor<CategoryEntity>(predicate: predicate)
        let categories = try context.fetch(descriptor)
        return categories.map { $0.toModel() }
    }
    
    func save(_ categories: [Category]) async throws {
        let descriptor = FetchDescriptor<CategoryEntity>()
        try context.fetch(descriptor).forEach { context.delete($0) }
        categories.forEach { category in
            context.insert(CategoryEntity(model: category))
        }
        
        try context.save()
    }
}


