import Foundation

/// Network response only; Core Data objects remain in the persistence layer.
struct AnnouncementDTO: Codable {
    let title: String
    let date: String
    let category: String
    let location: String
    let priorityLevel: String
}
