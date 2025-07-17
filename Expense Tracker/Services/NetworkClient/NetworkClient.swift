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
            throw URLError(.badURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method
        urlRequest.httpBody = request.body
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.headers.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil)
        }
        
        do {
            let decoded = try JSONDecoder().decode(Request.Response.self, from: data)
            return decoded
        } catch {
            throw NSError(domain: "DecodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response"])
        }
    }
}
