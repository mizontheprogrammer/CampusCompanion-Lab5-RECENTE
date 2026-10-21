import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(
            name: "CampusCompanion",
            managedObjectModel: Self.managedObjectModel
        )

        for description in container.persistentStoreDescriptions {
            if let url = description.url {
                do {
                    try Self.migrateLegacyStoreIfNeeded(at: url)
                } catch {
                    fatalError("Unable to migrate announcements: \(error)")
                }
            }
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
        }
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Unable to load the persistent store: \(error)")
            }
        }

        return container
    }()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        _ = persistentContainer
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func saveContext() {
        let context = persistentContainer.viewContext

        guard context.hasChanges else {
            return
        }

        do {
            try context.save()
        } catch {
            assertionFailure("Unable to save the persistent store: \(error)")
        }
    }

    static let managedObjectModel: NSManagedObjectModel = {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "CampusAnnouncement"
        entity.managedObjectClassName = NSStringFromClass(CampusAnnouncement.self)

        entity.properties = [
            attribute(named: "title"),
            attribute(named: "date"),
            attribute(named: "category"),
            attribute(named: "priority"),
            attribute(named: "postedBy"),
            attribute(named: "location", defaultValue: "Campus"),
            attribute(named: "priorityLevel", defaultValue: "Normal")
        ]

        model.entities = [entity]
        return model
    }()

    // The previous exercise built its model in code, so there is no bundled
    // .mom version for Core Data to discover. Supply that exact source model.
    static var legacyManagedObjectModel: NSManagedObjectModel {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "CampusAnnouncement"
        entity.managedObjectClassName = NSStringFromClass(CampusAnnouncement.self)
        entity.properties = ["title", "date", "category", "priority", "postedBy"]
            .map { attribute(named: $0) }
        model.entities = [entity]
        return model
    }

    static func migrateLegacyStoreIfNeeded(at url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(
            ofType: NSSQLiteStoreType, at: url, options: nil
        )
        guard !managedObjectModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) else {
            return
        }
        let sourceModel = legacyManagedObjectModel
        // Unknown store versions are left to Core Data's normal error handling.
        guard sourceModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) else {
            return
        }
        let mapping = try NSMappingModel.inferredMappingModel(
            forSourceModel: sourceModel, destinationModel: managedObjectModel
        )
        let temporaryURL = url.deletingLastPathComponent()
            .appendingPathComponent("Migration-\(UUID().uuidString).sqlite")
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        defer {
            try? coordinator.destroyPersistentStore(at: temporaryURL, ofType: NSSQLiteStoreType, options: nil)
        }
        let manager = NSMigrationManager(sourceModel: sourceModel, destinationModel: managedObjectModel)
        try manager.migrateStore(from: url, sourceType: NSSQLiteStoreType, options: nil,
                                 with: mapping, toDestinationURL: temporaryURL,
                                 destinationType: NSSQLiteStoreType, destinationOptions: nil)
        let temporaryStore = try coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType, configurationName: nil, at: temporaryURL
        )
        let migrationContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        migrationContext.persistentStoreCoordinator = coordinator
        try migrationContext.performAndWait {
            for announcement in try migrationContext.fetch(CampusAnnouncement.fetchRequest()) {
                announcement.priorityLevel = announcement.priority
            }
            try migrationContext.save()
            migrationContext.reset()
        }
        try coordinator.remove(temporaryStore)
        try coordinator.replacePersistentStore(at: url, destinationOptions: nil,
                                               withPersistentStoreFrom: temporaryURL,
                                               sourceOptions: nil, ofType: NSSQLiteStoreType)
    }

    private static func attribute(named name: String, defaultValue: String? = nil) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = false
        attribute.defaultValue = defaultValue
        return attribute
    }
}
