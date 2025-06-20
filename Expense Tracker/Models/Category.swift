import Foundation

enum Direction {
    case income, outcome
}

struct Category: Hashable {
    let id: Int
    let name: String
    let emoji: Character
    let direction: Direction
}
