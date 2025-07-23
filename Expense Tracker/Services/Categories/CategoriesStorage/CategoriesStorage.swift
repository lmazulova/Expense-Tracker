import SwiftData
import Foundation

@MainActor
final class CategoriesStorage: CategoriesStorageProtocol {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
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
        let existing = try context.fetch(FetchDescriptor<CategoryModel>())
        let existingIds = Set(existing.map { $0.id })
        
        for category in categories {
            guard !existingIds.contains(category.id) else {
                continue
            }
            
            let model = CategoryModel(from: category)
            context.insert(model)
        }
        
        try context.save()
    }
}


