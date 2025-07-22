import SwiftData
import Foundation

@MainActor
final class CategoriesStorage: CategoriesStorageProtocol {
    private let context: ModelContext
    private let container: ModelContainer
    
    init() {
        self.container = try! ModelContainer(for: CategoryModel.self)
        self.context = ModelContext(container)
    }
    
    func getAllCategories() async throws -> [Category] {
        let descriptor = FetchDescriptor<CategoryModel>()
        let categories = try context.fetch(descriptor)
        return categories.map { $0.toDTO() }
    }
    
    func getCategories(by direction: Direction) async throws -> [Category] {
        let isIncome = direction == .income
        let predicate = #Predicate<CategoryModel> { $0.isIncome == isIncome }
        let descriptor = FetchDescriptor<CategoryModel>(predicate: predicate)
        let categories = try context.fetch(descriptor)
        return categories.map { $0.toDTO() }
    }
    
    func save(_ categories: [Category]) async throws {
        let descriptor = FetchDescriptor<CategoryModel>()
        try context.fetch(descriptor).forEach { context.delete($0) }
        categories.forEach { category in
            context.insert(CategoryModel(from: category))
        }
        
        try context.save()
    }
}


