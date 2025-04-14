import SwiftData
import Foundation

@Model
final class Tail: Identifiable {
    @Attribute(.unique) var id: Int
    var title: String
    var summaries: [Summary]
    var latitude: Double?
    var longitude: Double?
    var visited: Bool = false
    
    init(id: Int, title: String, summaries: [Summary], latitude: Double? = nil, longitude: Double? = nil) {
        self.id = id
        self.title = title
        self.summaries = summaries
        self.latitude = latitude
        self.longitude = longitude
    }
    
    static func randomIdGenerator(currentList: [Int]) -> [Int] {
        let range = 1..<60000
        let numOfIdRequired = 3
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

extension Tail {
    static func fromDTO(_ dto: TailDTO) -> Tail {
        let summaryModels = dto.summaries.map { Summary(text: $0) }
        return Tail(id: dto.id, title: dto.title, summaries: summaryModels)
    }
}

@Model
class Summary {
    var text: String
    init(text: String) {
        self.text = text
    }
}

struct TailDTO: Decodable {
    let id: Int
    let title: String
    let summaries: [String]
}

struct TailListDTO: Decodable {
    var results: [TailDTO]
}
