import Foundation

enum Direction: Sendable {
    case income, outcome
}

extension Direction: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Bool.self)
        self = value ? .income : .outcome
    }
}
