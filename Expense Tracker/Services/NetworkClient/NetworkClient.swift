import Foundation
import SwiftKeychainWrapper

final class NetworkClient {
    private let baseURL = URL(string: "https://shmr-finance.ru/api/v1")!
    private let token: String
    
    init() {
        if let token = KeychainWrapper.standard.string(forKey: "userToken") {
            self.token = token
        } else {
            self.token = ""
        }
    }
    
    func send<Request: NetworkRequest>(_ request: Request) async throws -> Request.Response {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(request.path), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = request.queryItems
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method
        urlRequest.httpBody = request.body
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.headers.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: urlRequest)
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                throw NetworkError.noInternet
            case .cancelled:
                throw NetworkError.cancelled
            default:
                throw NetworkError.unknown(urlError)
            }
        } catch {
            throw NetworkError.unknown(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            break
        case 401:
            throw NetworkError.unauthorized
        case 400..<500, 500..<600:
            throw NetworkError.serverError(code: httpResponse.statusCode)
        default:
            throw NetworkError.invalidResponse
        }
        do {
            let decoded = try JSONDecoder().decode(Request.Response.self, from: data)
            return decoded
        } catch {
            print("Decoding error: ", error)
            throw NetworkError.decodingError
        }
    }
}
