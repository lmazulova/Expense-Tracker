import Foundation

enum Currency: String, CaseIterable {
    case rub = "₽"
    case usd = "$"
    case eur = "€"
}

extension Currency: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let code = try container.decode(String.self)
        switch code {
        case "RUB": self = .rub
        case "USD": self = .usd
        case "EUR": self = .eur
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown currency code: \(code)")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .rub: try container.encode("RUB")
        case .usd: try container.encode("USD")
        case .eur: try container.encode("EUR")
        }
    }
}
