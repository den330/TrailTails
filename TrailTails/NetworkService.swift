//
//  NetworkService.swift
//  TrailTails
//
//  Created by yaxin on 2025-04-06.
//

import Foundation

@MainActor
class NetworkService {
    enum NetworkError: Error, LocalizedError {
        case networkError(underlyingError: Error?)
        var errorDescription: String? {
            switch self {
            case .networkError(let error):
                return "A network error occurred. The server is not accessible at the moment, please try again later. \(error?.localizedDescription ?? "")"
            }
        }
    }
    static let baseUrl = URL(string: "https://gutendex.com")!
    
    
    static func fetchTails(idList: [Int]) async throws -> [Tail] {
        var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)!
        components.path = "/books"
        components.queryItems = [URLQueryItem(name: "ids", value: "\(idList.map {String($0)}.joined(separator: ","))")]
        var urlRequest = URLRequest(url: components.url!)
        urlRequest.httpMethod = "GET"
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10.0
        let session = URLSession(configuration: configuration)
        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkError.networkError(underlyingError: nil)
            }
            print("response is back \(response.statusCode)")
            let decoder = JSONDecoder()
            let tails = try decoder.decode(TailListDTO.self, from: data)
            var tailArr: [Tail] = []
            tails.results.forEach {
                tailArr.append(Tail.fromDTO($0))
            }
            return tailArr
        } catch {
            throw NetworkError.networkError(underlyingError: error)
        }
    }
}
