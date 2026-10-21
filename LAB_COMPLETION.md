# Laboratory Completion Checklist

## Exercise 1 - Environment, Storyboard UI, and Auto Layout

- [x] Created a Storyboard-based UIKit application structure.
- [x] Added **Campus Companion** title, **Your Campus, In Your Pocket** subtitle, and an aspect-fit campus image.
- [x] Used Auto Layout inside a scroll view so the interface stays usable on small and large phones.
- [x] Connected the title and subtitle labels to Swift using `IBOutlet`.
- [x] Added a **Get Started** button connected through `IBAction`.
- [x] Tapping the button changes the subtitle to **Let's get started!**.
- [x] Produced iPhone SE and iPhone 15 Pro-sized evidence images.

## Exercise 2 - Navigation, User Input, and Data Passing

- [x] Embedded the welcome screen in a Navigation Controller.
- [x] Added **Explore Campus** and a detail scene.
- [x] Added a name field, notification switch, and Student/Faculty segmented control.
- [x] Added the coding-challenge inputs: preferred event date and guest stepper.
- [x] Connected all inputs with `IBOutlet` and the Explore action with `IBAction`.
- [x] Dismissed the keyboard before navigation.
- [x] Passed values using `prepare(for:sender:)` and `ShowDetailSegue`.
- [x] Used safe defaults: **Student**, notifications off, current date, and one guest.
- [x] Displayed every captured value on `DetailViewController`.

## Exercise 3 - Announcements, Custom Cells, and Row Details

- [x] Defined `CampusAnnouncement` with title, date, category, priority, and posted-by fields.
- [x] Included six sample announcements.
- [x] Added the **Campus Announcements** button and a table-view controller.
- [x] Built a custom reusable `AnnouncementCell` with icon and three labels.
- [x] Reset every reusable visual property in `prepareForReuse()` and `configure(with:)`.
- [x] Distinguished urgent rows using warning imagery, red tint, and a subtle red background.
- [x] Implemented selection, deselection, and `ShowAnnouncementDetailSegue`.
- [x] Displayed title, date, category, priority, and posting office on the detail screen.
- [x] Preserved the original personalized Explore Campus detail flow.

## Verification Summary

| Check | Result |
| --- | --- |
| Storyboard/plist/scheme XML parse | Passed |
| Asset JSON parse | Passed |
| Storyboard outlet-to-Swift matching | 13/13 passed |
| Storyboard action-to-Swift matching | 3/3 passed |
| Named segue matching | 2/2 passed |
| Announcement records | 6 present |
| Required announcement fields | 5/5 present |
| Browser JavaScript syntax | Passed |
| Responsive evidence inspection | Passed at 375 × 667 and 393 × 852 |

## Exercise 4 - UserDefaults Reset and Core Data Deletion

- [x] Added named UserDefaults keys for the student name, notification setting, and role index.
- [x] Saved all three welcome-screen values before the Explore Campus segue.
- [x] Restored all three values in `viewDidLoad()` with safe defaults.
- [x] Added a Reset Preferences control to the welcome screen.
- [x] Removed all three saved values with `UserDefaults.standard.removeObject(forKey:)`.
- [x] Immediately reset the name field, notification switch, and role segment to their defaults.
- [x] Replaced the in-memory announcement array with Core Data managed objects.
- [x] Seeded the six initial announcements only once.
- [x] Implemented swipe-to-delete using `tableView(_:commit:forRowAt:)`.
- [x] Deleted the managed object with `context.delete(_:)` and persisted the change with `context.save()`.
- [x] Removed the deleted object from the table data source and deleted the table row.
- [x] Preserved deletion after the application is terminated and relaunched.

| Exercise 4 check | Result |
| --- | --- |
| Reset action connection | Present in `Main.storyboard` |
| UserDefaults removal calls | 3 present |
| Core Data context deletion | Present |
| Core Data save after deletion | Present |
| Native iOS build | Requires Xcode/macOS; not available in this environment |

Native compilation requires Apple's iOS SDK on macOS. The included browser preview is the verified no-Xcode execution path for this deliverable.
