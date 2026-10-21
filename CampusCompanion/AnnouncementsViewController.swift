import UIKit
import CoreData

private enum RemoteEndpoint {
    // The PDF's repository currently returns 404. Retain its address for restoration.
    static let instructorAnnouncements = URL(
        string: "https://raw.githubusercontent.com/feu-mad2/" +
            "campus-companion-api/main/announcements.json"
    )!

    // Transparent demo alternative: a real HTTPS GET returns these sample JSON bytes.
    // This public HTTP testing service echoes the payload encoded in the URL.
    private static let demoPayload =
        "WwogIHsKICAgICJ0aXRsZSI6ICJNaWR0ZXJtIEV4YW0gU2NoZWR1bGUiLAogICAgImRhdGUiOiAiMjAyNi0xMC0yNSIsCiAgICAi" +
        "Y2F0ZWdvcnkiOiAiQWNhZGVtaWMiLAogICAgImxvY2F0aW9uIjogIkxpYnJhcnksIFJvb20gMjEwIiwKICAgICJwcmlvcml0eUxl" +
        "dmVsIjogIkhpZ2giCiAgfSwKICB7CiAgICAidGl0bGUiOiAiTGlicmFyeSBFeHRlbmRlZCBIb3VycyIsCiAgICAiZGF0ZSI6ICIy" +
        "MDI2LTEwLTI2IiwKICAgICJjYXRlZ29yeSI6ICJHZW5lcmFsIiwKICAgICJsb2NhdGlvbiI6ICJNYWluIExpYnJhcnkiLAogICAg" +
        "InByaW9yaXR5TGV2ZWwiOiAiTWVkaXVtIgogIH0sCiAgewogICAgInRpdGxlIjogIkNvdW5jaWwgRWxlY3Rpb24gUmVzdWx0cyIs" +
        "CiAgICAiZGF0ZSI6ICIyMDI2LTEwLTI3IiwKICAgICJjYXRlZ29yeSI6ICJBbm5vdW5jZW1lbnQiLAogICAgImxvY2F0aW9uIjog" +
        "IlN0dWRlbnQgQ291bmNpbCBPZmZpY2UiLAogICAgInByaW9yaXR5TGV2ZWwiOiAiTG93IgogIH0KXQ=="
    static let announcements = URL(
        string: "https://httpbingo.org/base64/" + demoPayload +
            "?content-type=application/json"
    )!
    static let sourceDescription = "HTTPS demo feed - sample data"
}

class AnnouncementsViewController: UITableViewController {

    private enum DefaultsKey {
        static let announcementsSeeded = "announcementsSeeded"
    }

    private var announcements: [CampusAnnouncement] = []
    private var isFetching = false
    private var selectedAnnouncement: CampusAnnouncement?

    private var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Campus Announcements"
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        let sourceLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 52))
        sourceLabel.text = "Demo feed • Sample announcements\nInstructor feed unavailable (404)"
        sourceLabel.font = .preferredFont(forTextStyle: .caption1)
        sourceLabel.textColor = .secondaryLabel
        sourceLabel.textAlignment = .center
        sourceLabel.numberOfLines = 2
        tableView.tableFooterView = sourceLabel
    }

    @IBAction func refreshTapped(_ sender: UIBarButtonItem) {
        fetchAnnouncementsFromServer()
    }

    func fetchAnnouncementsFromServer() {
        guard !isFetching else { return }
        isFetching = true
        navigationItem.rightBarButtonItem?.isEnabled = false

        let task = URLSession.shared.dataTask(
            with: RemoteEndpoint.announcements
        ) { [weak self] data, response, error in
            defer {
                DispatchQueue.main.async {
                    self?.isFetching = false
                    self?.navigationItem.rightBarButtonItem?.isEnabled = true
                }
            }
            // Inspect transport error, HTTP status, then data, in that order.
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Unexpected server response.")
                return
            }
            guard let data = data else { return }
            print("Feed source: \(RemoteEndpoint.sourceDescription)")
            print("Reached network handler with \(data.count) bytes.")
            if let json = String(data: data, encoding: .utf8) {
                print("Raw announcements JSON:\n\(json)")
            }
            do {
                let decodedAnnouncements = try JSONDecoder().decode(
                    [AnnouncementDTO].self, from: data
                )
                DispatchQueue.main.async {
                    guard let self else { return }
                    if self.replaceAnnouncements(with: decodedAnnouncements) {
                        self.showNetworkConfirmationAlert(byteCount: data.count)
                    }
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
        task.resume()
    }

    /// Replace and save atomically so repeated refreshes never duplicate rows.
    @discardableResult
    func replaceAnnouncements(with dtos: [AnnouncementDTO]) -> Bool {
        do {
            let existing = try context.fetch(CampusAnnouncement.fetchRequest())
            for item in existing { context.delete(item) }
            for dto in dtos {
                let announcement = NSEntityDescription.insertNewObject(
                    forEntityName: "CampusAnnouncement", into: context
                ) as! CampusAnnouncement
                announcement.title = dto.title
                announcement.date = dto.date
                announcement.category = dto.category
                announcement.location = dto.location
                announcement.priorityLevel = dto.priorityLevel
                // Preserve the earlier milestone's required, nonoptional fields.
                announcement.priority = dto.priorityLevel
                announcement.postedBy = "Campus Announcements"
            }
            try context.save()
            UserDefaults.standard.set(true, forKey: DefaultsKey.announcementsSeeded)
            selectedAnnouncement = nil
            loadAnnouncements()
            return true
        } catch {
            context.rollback()
            presentPersistenceError(error)
            return false
        }
    }

    func showNetworkConfirmationAlert(byteCount: Int) {
        let alert = UIAlertController(
            title: "Server Reached",
            message: "Received \(byteCount) bytes from the announcements endpoint.\n\nSource: \(RemoteEndpoint.sourceDescription).",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAnnouncements()
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        announcements.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "AnnouncementCell",
            for: indexPath
        ) as? AnnouncementCell else {
            return UITableViewCell()
        }

        cell.configure(with: announcements[indexPath.row])
        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        canEditRowAt indexPath: IndexPath
    ) -> Bool {
        return true
    }

    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete,
              announcements.indices.contains(indexPath.row) else {
            return
        }

        let announcement = announcements[indexPath.row]
        context.delete(announcement)

        do {
            try context.save()
            announcements.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            context.rollback()
            loadAnnouncements()
            presentPersistenceError(error)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedAnnouncement = announcements[indexPath.row]
        performSegue(withIdentifier: "ShowAnnouncementDetailSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowAnnouncementDetailSegue",
              let destination = segue.destination as? DetailViewController,
              let selectedAnnouncement else {
            return
        }

        destination.announcement = selectedAnnouncement
    }

    private func loadAnnouncements() {
        do {
            let storedAnnouncements = try context.fetch(CampusAnnouncement.fetchRequest())

            if storedAnnouncements.isEmpty && !UserDefaults.standard.bool(
                forKey: DefaultsKey.announcementsSeeded
            ) {
                try seedAnnouncements()
            } else if !storedAnnouncements.isEmpty {
                UserDefaults.standard.set(true, forKey: DefaultsKey.announcementsSeeded)
            }

            announcements = try context.fetch(CampusAnnouncement.fetchRequest())
            tableView.reloadData()
        } catch {
            context.rollback()
            presentPersistenceError(error)
        }
    }

    private func seedAnnouncements() throws {
        for seed in CampusAnnouncement.seedData {
            let announcement = NSEntityDescription.insertNewObject(
                forEntityName: "CampusAnnouncement", into: context
            ) as! CampusAnnouncement
            announcement.title = seed.title
            announcement.date = seed.date
            announcement.category = seed.category
            announcement.priority = seed.priority
            announcement.postedBy = seed.postedBy
            announcement.location = "Campus"
            announcement.priorityLevel = seed.priority
        }

        try context.save()
        UserDefaults.standard.set(true, forKey: DefaultsKey.announcementsSeeded)
    }

    private func presentPersistenceError(_ error: Error) {
        let alert = UIAlertController(
            title: "Unable to Save Changes",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
