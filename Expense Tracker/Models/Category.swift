import Foundation

struct Category: Hashable, Identifiable, Sendable {
    let id: Int
    let name: String
    let emoji: Character
    let direction: Direction
    
    init(id: Int, name: String, emoji: Character, direction: Direction) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.direction = direction
    }
}

extension Category: Decodable {
    enum CodingKeys: String, CodingKey {
        case id, name, emoji, isIncome
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        let emojiString = try container.decode(String.self, forKey: .emoji)
        guard let firstChar = emojiString.first else {
            throw DecodingError.dataCorruptedError(forKey: .emoji, in: container, debugDescription: "Emoji must be a single character string")
        }
        emoji = firstChar
        
        direction = try container.decode(Direction.self, forKey: .isIncome)
    }
}
