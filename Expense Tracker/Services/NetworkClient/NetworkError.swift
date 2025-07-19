import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(code: Int)
    case decodingError
    case encodingError
    case noInternet
    case cancelled
    case unknown(Error)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL."
        case .invalidResponse:
            return "Некорректный ответ от сервера."
        case .unauthorized:
            return "Вы не авторизованы."
        case .serverError(let code):
            return "Ошибка сервера (код \(code))."
        case .decodingError:
            return "Не удалось декодировать ответ."
        case .encodingError:
            return "Не удалось закодировать запрос."
        case .noInternet:
            return "Отсутствует подключение к интернету."
        case .cancelled:
            return "Запрос отменён."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
