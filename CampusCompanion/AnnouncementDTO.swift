import Foundation

/// Network response only; Core Data objects remain in the persistence layer.
struct AnnouncementDTO: Codable {
    let title: String
    let date: String
    let category: String
    let location: String
    let priorityLevel: String

    enum CodingKeys: String, CodingKey {
        case title, date, category, location, priorityLevel
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decode(String.self, forKey: .title)
        date = try values.decode(String.self, forKey: .date)
        category = try values.decode(String.self, forKey: .category)
        location = try values.decodeIfPresent(String.self, forKey: .location) ?? "Not specified"
        priorityLevel = try values.decodeIfPresent(String.self, forKey: .priorityLevel) ?? "Not specified"
    }
}
