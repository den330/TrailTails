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
    private let baseUrl = URL(string: "")!
    static func fetchTails() async throws -> [Tail] {
//        let (data, response) = try await URLSession.shared.data(from: baseUrl)
//        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
//            throw NetworkError.networkError
//        }
//        let decoder = JSONDecoder()
//        let tails = try decoder.decode([Tail].self, from: data)
//        return tails
        guard let url = Bundle.main.url(forResource: "Tail", withExtension: "json") else {
            print("no json file found")
            return []
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let myData = try decoder.decode([Tail].self, from: data)
        return myData
    }
}
