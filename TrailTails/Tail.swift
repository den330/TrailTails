//
//  Tail.swift
//  TrailTails
//
//  Created by yaxin on 2025-04-06.
//
import SwiftData
import Foundation
import MapKit

@Model
final class Tail: Decodable {
    @Attribute(.unique) var id: Int
    var title: String
    var summaries: [String]
    var latitude: Double?
    var longitude: Double?
    enum CodingKeys: CodingKey {
        case id
        case title
        case summaries
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        summaries = try container.decode([String].self, forKey: .summaries)
    }
    
    static func randomIdGenerator(currentList: [Int]) -> [Int] {
        let range = 1..<60000
        let numOfIdRequired = 5
        var res = [Int]()
        while true {
            if res.count == numOfIdRequired {
                break
            }
            let randomValue = Int.random(in: range)
            if !currentList.contains(randomValue) {
                res.append(Int.random(in: range))
            }
        }
        return res
    }
}
