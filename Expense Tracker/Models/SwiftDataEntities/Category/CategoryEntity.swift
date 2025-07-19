import SwiftData
import Foundation

@Model
final class CategoryEntity {
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
    
    convenience init(model: Category) {
        self.init(
            id: model.id,
            name: model.name,
            emoji: String(model.emoji),
            isIncome: model.direction == .income
        )
    }
}

//MARK: - Преобразование и entity в model
extension CategoryEntity {
    func toModel() -> Category {
        Category(
            id: id,
            name: name,
            emoji: emoji.first ?? "🤷‍♂",
            direction: isIncome ? .income : .outcome
        )
    }
}
