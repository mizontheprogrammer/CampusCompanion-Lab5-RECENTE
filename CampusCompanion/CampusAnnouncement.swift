import CoreData

@objc(CampusAnnouncement)
class CampusAnnouncement: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var date: String
    @NSManaged var category: String
    @NSManaged var priority: String
    @NSManaged var postedBy: String

    @NSManaged var location: String
    @NSManaged var priorityLevel: String

    struct Seed {
        let title: String
        let date: String
        let category: String
        let priority: String
        let postedBy: String
    }

    @nonobjc class func fetchRequest() -> NSFetchRequest<CampusAnnouncement> {
        NSFetchRequest<CampusAnnouncement>(entityName: "CampusAnnouncement")
    }

    static let seedData: [Seed] = [
        Seed(
            title: "Enrollment Period Extended",
            date: "August 3, 2026",
            category: "Academics",
            priority: "Urgent",
            postedBy: "Registrar"
        ),
        Seed(
            title: "Campus Wi-Fi Maintenance",
            date: "August 7, 2026",
            category: "Technology",
            priority: "Urgent",
            postedBy: "IT Services"
        ),
        Seed(
            title: "Student Organization Fair",
            date: "August 12, 2026",
            category: "Student Life",
            priority: "Normal",
            postedBy: "Student Affairs"
        ),
        Seed(
            title: "Library Extended Hours",
            date: "August 15, 2026",
            category: "Facilities",
            priority: "Normal",
            postedBy: "University Library"
        ),
        Seed(
            title: "Scholarship Applications Open",
            date: "August 20, 2026",
            category: "Financial Aid",
            priority: "Normal",
            postedBy: "Scholarships Office"
        ),
        Seed(
            title: "Emergency Preparedness Drill",
            date: "August 25, 2026",
            category: "Safety",
            priority: "Urgent",
            postedBy: "Campus Security"
        )
    ]
}
