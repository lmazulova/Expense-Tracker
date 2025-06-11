import Foundation

final class CategoriesService {
    private let allCategories: [Category] = [
        Category(
            id: 1,
            name: "Еда",
            emoji: "🍔",
            isIncome: .outcome
        ),
        Category(
            id: 2,
            name: "Зарплата",
            emoji: "💰",
            isIncome: .income
        ),
        Category(
            id: 3,
            name: "Транспорт",
            emoji: "🚌",
            isIncome: .outcome
        )
    ]
    
    func categories() async throws -> [Category] {
        allCategories
    }
    
    func categories(with direction: Direction) async throws -> [Category] {
        allCategories.filter{ $0.isIncome == direction }
    }
}
