# Campus Companion — Laboratory Exercise 5

Storyboard-based UIKit iOS app with on-demand REST requests using URLSession, Codable JSON decoding, and Core Data persistence.

## Open and run

1. Open `CampusCompanion.xcodeproj` in Xcode.
2. Select the **CampusCompanion** scheme and an iPhone Simulator, then Run.
3. Open **Campus Announcements** and tap the Refresh arrow.
4. After a successful request, dismiss **Server Reached** to view Location and Priority Level in the updated list.

## Included files

- `CampusCompanion/`: complete Swift sources, storyboards, asset catalog, and Info.plist.
- `CampusCompanion.xcodeproj/`: Xcode project and shared scheme.
- `Tests/AnnouncementNetworkingTests.swift`: decoding, legacy-store migration, and mocked refresh/failure tests.
- `Evidence/`: screenshots, sample JSON, and test-result notes supplied in the uploaded project.
- `LAB5_REFLECTION.txt`, `LAB5_STATUS.txt`, and `LAB5_DEMO_FEED.txt`: reflection and implementation notes.
- `WebPreview/`: earlier-exercise browser preview; verify the Lab 5 native app in Xcode.
- `announcements.json`: publicly accessible sample announcement feed.

## Public sample JSON API

**GET** https://raw.githubusercontent.com/mizontheprogrammer/CampusCompanion-Lab5-RECENTE/main/announcements.json

No API key is required to read this public sample file. It contains fictional demonstration announcements, not an official campus service.

Each object contains `title`, `date`, `category`, `location`, and `priorityLevel` as strings. See [announcements.json](announcements.json).

The source in the submitted ZIP currently uses an explicitly labeled httpbingo HTTPS demo feed because the original instructor GitHub endpoint returned 404. This upload preserves that app behavior. To use this repository's feed, update `RemoteEndpoint.announcements` and the visible source labels in `AnnouncementsViewController.swift`.

## Verification

The included test notes record three successful Simulator tests. HTTP demo verification and screenshots are labeled as sample data. These historical notes describe the supplied project snapshot; this repository upload does not imply that the instructor's original feed was repaired.
