import Foundation

struct GetCategoriesRequest: NetworkRequest {
    typealias Response = [Category]

    var path: String { "/categories" }
    var method: String { "GET" }
    var headers: [String : String] { [:] }
    var queryItems: [URLQueryItem] { [] }
    var body: Data? { nil }
}
