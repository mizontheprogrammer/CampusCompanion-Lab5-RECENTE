import XCTest
import CoreData
@testable import CampusCompanion

private final class FeedProtocol: URLProtocol {
    static var status = 200
    static var body = Data()
    static var failure: Error?
    static var didRespond: (() -> Void)?

    override class func canInit(with request: URLRequest) -> Bool {
        ["raw.githubusercontent.com", "httpbingo.org"].contains(request.url?.host ?? "")
    }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        if let failure = Self.failure {
            client?.urlProtocol(self, didFailWithError: failure)
        } else {
            client?.urlProtocol(self, didReceive: HTTPURLResponse(
                url: request.url!, statusCode: Self.status,
                httpVersion: nil, headerFields: ["Content-Type": "application/json"]
            )!, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: Self.body)
            client?.urlProtocolDidFinishLoading(self)
        }
        Self.didRespond?()
    }
    override func stopLoading() {}
}

final class AnnouncementNetworkingTests: XCTestCase {
    private let sample = Data("""
    [{"title":"Server Test Announcement","date":"2026-10-20","category":"General","location":"Main Library","priorityLevel":"High"}]
    """.utf8)

    func testDTORequiresChallengeFields() throws {
        let decoded = try JSONDecoder().decode([AnnouncementDTO].self, from: sample)
        XCTAssertEqual(decoded.first?.location, "Main Library")
        XCTAssertEqual(decoded.first?.priorityLevel, "High")
        XCTAssertThrowsError(try JSONDecoder().decode([AnnouncementDTO].self,
            from: Data("[{\"title\":\"Incomplete\",\"date\":\"Today\",\"category\":\"General\"}]".utf8)))
    }

    @MainActor
    func testLegacyStoreMigrationAndReopen() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let url = folder.appendingPathComponent("Announcements.sqlite")
        let old = NSPersistentStoreCoordinator(managedObjectModel: AppDelegate.legacyManagedObjectModel)
        let store = try old.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url)
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = old
        let item = NSEntityDescription.insertNewObject(
                forEntityName: "CampusAnnouncement", into: context
            ) as! CampusAnnouncement
        item.title = "Existing announcement"
        item.date = "2026-10-20"
        item.category = "General"
        item.priority = "Urgent"
        item.postedBy = "Registrar"
        try context.save()
        context.reset()
        try old.remove(store)
        try AppDelegate.migrateLegacyStoreIfNeeded(at: url)
        for _ in 0..<2 {
            let current = NSPersistentStoreCoordinator(managedObjectModel: AppDelegate.managedObjectModel)
            let reopened = try current.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url)
            let reopenedContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            reopenedContext.persistentStoreCoordinator = current
            let rows = try reopenedContext.fetch(CampusAnnouncement.fetchRequest())
            XCTAssertEqual(rows.count, 1)
            XCTAssertEqual(rows.first?.title, "Existing announcement")
            XCTAssertEqual(rows.first?.location, "Campus")
            XCTAssertEqual(rows.first?.priorityLevel, "Urgent")
            reopenedContext.reset()
            try current.remove(reopened)
        }
    }

    @MainActor
    func testRefreshPipelineAndFailures() async throws {
        URLProtocol.registerClass(FeedProtocol.self)
        defer { URLProtocol.unregisterClass(FeedProtocol.self) }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // Isolate test records from the user's persistent store.
        let originalContainer = appDelegate.persistentContainer
        let container = NSPersistentContainer(name: "Tests", managedObjectModel: originalContainer.managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in XCTAssertNil(error) }
        appDelegate.persistentContainer = container
        let seeded = UserDefaults.standard.bool(forKey: "announcementsSeeded")
        defer {
            appDelegate.persistentContainer = originalContainer
            UserDefaults.standard.set(seeded, forKey: "announcementsSeeded")
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AnnouncementsViewController") as! AnnouncementsViewController
        controller.loadViewIfNeeded()
        let navigation = UINavigationController(rootViewController: controller)
        let scene = UIApplication.shared.connectedScenes.first as! UIWindowScene
        let window = scene.windows.first(where: { $0.isKeyWindow })!
        let originalRoot = window.rootViewController
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        defer { window.rootViewController = originalRoot }
        try await Task.sleep(nanoseconds: 1_000_000_000)
        XCTAssertNotNil(controller.navigationItem.rightBarButtonItem?.action)
        FeedProtocol.body = sample
        FeedProtocol.status = 200
        FeedProtocol.failure = nil
        await refresh(controller)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 1)
        var stored = try container.viewContext.fetch(CampusAnnouncement.fetchRequest())
        XCTAssertEqual(stored.first?.title, "Server Test Announcement")
        XCTAssertEqual(stored.first?.location, "Main Library")
        XCTAssertEqual(stored.first?.priorityLevel, "High")
        XCTAssertEqual((controller.presentedViewController as? UIAlertController)?.title, "Server Reached")
        await dismissAlert(controller)
        await refresh(controller)
        XCTAssertEqual(try container.viewContext.count(for: CampusAnnouncement.fetchRequest()), 1)
        await dismissAlert(controller)
        for failure in ["http", "decode", "offline"] {
            FeedProtocol.status = failure == "http" ? 404 : 200
            FeedProtocol.body = failure == "decode" ? Data("invalid JSON".utf8) : sample
            FeedProtocol.failure = failure == "offline" ? URLError(.notConnectedToInternet) : nil
            await refresh(controller)
            stored = try container.viewContext.fetch(CampusAnnouncement.fetchRequest())
            XCTAssertEqual(stored.count, 1)
            XCTAssertEqual(stored.first?.location, "Main Library")
            XCTAssertNil(controller.presentedViewController)
        }
        XCTAssertTrue(controller.replaceAnnouncements(with: []))
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 0)
    }

    @MainActor
    private func dismissAlert(_ controller: UIViewController) async {
        guard controller.presentedViewController != nil else { return }
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            controller.dismiss(animated: false) { continuation.resume() }
        }
    }

    @MainActor
    private func refresh(_ controller: AnnouncementsViewController) async {
        let responded = expectation(description: "Feed responded")
        FeedProtocol.didRespond = { responded.fulfill() }
        controller.refreshTapped(controller.navigationItem.rightBarButtonItem!)
        await fulfillment(of: [responded], timeout: 15)
        // Wait for the request callback's queued UI work instead of racing it.
        for _ in 0..<150 {
            if controller.navigationItem.rightBarButtonItem?.isEnabled == true { break }
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
        XCTAssertEqual(controller.navigationItem.rightBarButtonItem?.isEnabled, true)
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
}
