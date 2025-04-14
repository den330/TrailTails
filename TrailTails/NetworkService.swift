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
        components.queryItems = [URLQueryItem(name: "ids", value: "\(idList.map {String($0)}.joined(separator: ","))")]
        var urlRequest = URLRequest(url: components.url!)
        urlRequest.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.networkError
        }
        print("response came back")
        let decoder = JSONDecoder()
        let tails = try decoder.decode(TailListDTO.self, from: data)
        var tailArr: [Tail] = []
        tails.results.forEach {
            tailArr.append(Tail.fromDTO($0))
        }
        return tailArr
    }
}
