//
//  Item.swift
//  TrailTails
//
//  Created by yaxin on 2025-04-05.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
