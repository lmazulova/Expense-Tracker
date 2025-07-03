import Foundation

final class CategoriesService {
    private let allCategories: [Category] = [
        Category(
            id: 1,
            name: "Еда",
            emoji: "🍔",
            direction: .outcome
        ),
        Category(
            id: 2,
            name: "Зарплата",
            emoji: "💰",
            direction: .income
        ),
        Category(
            id: 3,
            name: "Транспорт",
            emoji: "🚌",
            direction: .outcome
        ),
        Category(
            id: 4,
            name: "Медицина ",
            emoji: "💊",
            direction: .outcome
        ),
        Category(
            id: 5,
            name: "Подработка",
            emoji: "💵",
            direction: .income
        ),
        Category(
            id: 6,
            name: "Развлечения",
            emoji: "💃",
            direction: .outcome
        ),
        Category(
            id: 7,
            name: "Кэшбек",
            emoji: "💸",
            direction: .income
        )
    ]
    
    func categories() async throws -> [Category] {
        allCategories
    }
    
    func categories(with direction: Direction) async throws -> [Category] {
        allCategories.filter{ $0.direction == direction }
    }
}
