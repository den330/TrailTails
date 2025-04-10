//
//  NetworkService.swift
//  TrailTails
//
//  Created by yaxin on 2025-04-06.
//

import Foundation

@MainActor
class NetworkService {
    enum NetworkError: Error {
        case networkError
    }
    static let baseUrl = URL(string: "https://gutendex.com")!
    
    
    static func fetchTails(idList: [Int]) async throws -> [Tail] {
        var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)!
        components.path = "/books"
        components.queryItems = [URLQueryItem(name: "id", value: "\(idList.map {String($0)}.joined(separator: ","))")]
        print("url is \(components.url!)")
        var urlRequest = URLRequest(url: components.url!)
        urlRequest.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.networkError
        }
        print("response is \(response) \(String(data: data, encoding: .utf8)!)")
        let decoder = JSONDecoder()
        let tails = try decoder.decode(TailList.self, from: data)
        print("how many tails \(tails.results.count)")
        return tails.results
    }
}
