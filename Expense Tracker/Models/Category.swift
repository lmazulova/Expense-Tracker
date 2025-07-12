import Foundation

enum Direction: Sendable {
    case income, outcome
}

struct Category: Hashable, Identifiable, Sendable {
    let id: Int
    let name: String
    let emoji: Character
    let direction: Direction
}

