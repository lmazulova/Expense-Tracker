import SwiftData
import Foundation

@Model
final class CategoryModel {
    @Attribute(.unique) var id: Int
    var name: String
    var emoji: String
    var isIncome: Bool

    init(id: Int, name: String, emoji: String, isIncome: Bool) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.isIncome = isIncome
    }
    
    convenience init(from dto: Category) {
        self.init(
            id: dto.id,
            name: dto.name,
            emoji: String(dto.emoji),
            isIncome: dto.direction == .income
        )
    }
}

//MARK: - Преобразование из model в структуру
extension CategoryModel {
    func toDTO() -> Category {
        Category(
            id: id,
            name: name,
            emoji: emoji[emoji.startIndex],
            direction: isIncome ? .income : .outcome
        )
    }
}
