//
//  Tail.swift
//  TrailTails
//
//  Created by yaxin on 2025-04-06.
//
import SwiftData
import Foundation

@Model
final class Tail {
    var id: UUID = UUID()
    var title: String
    var content: String
    init(title: String, content: String) {
        self.title = title
        self.content = content
    }
}
