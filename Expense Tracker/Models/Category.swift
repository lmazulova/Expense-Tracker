import Foundation

enum Direction {
    case income, outcome
}

struct Category {
    let id: Int
    let name: String
    let emoji: Character
    let isIncome: Direction
}
