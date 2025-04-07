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
    @Attribute(.unique) var id: String
    var title: String
    var content: String
    enum CodingKeys: CodingKey {
        case id
        case title
        case content
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
    }
}
