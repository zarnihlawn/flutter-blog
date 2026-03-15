# Brutal Blog (7CC012 Coursework)

Offline-first Flutter blogging client with SQLite persistence, camera/gallery image attachments, search, bulk delete, and sharing to social apps.

## Features Implemented

- Create, edit, view, and delete individual messages.
- View message list and individual message detail pages.
- Search message text with highlighted matches.
- Multi-select mode with bulk delete.
- SQLite local storage using `sqflite`.
- Attach images from gallery and camera.
- Share text/image message content to social platforms via share sheet.
- Connectivity awareness banner with online/offline status.
- Brutalist design system and animated UI transitions.

## Marking Criteria Mapping

- Offline message management and search: implemented in `messages_home_screen.dart`, `message_detail_screen.dart`, `message_editor_screen.dart`, and `message_controller.dart`.
- SQLite storage: implemented in `database_service.dart` and `message_repository.dart`.
- Attach image from gallery/camera: implemented in `message_editor_screen.dart` and `message_controller.dart`.
- Upload/share individual message online: implemented in `message_detail_screen.dart` and `message_controller.dart`.
- Demonstration readiness: see `REPORT.md` for scripted demo flow.

## Packages Used

- `provider` for state management.
- `sqflite` and `path` for local database.
- `image_picker` for camera/gallery attachments.
- `share_plus` for social sharing.
- `connectivity_plus` for network status handling.
- `intl` for date formatting.

## Run Instructions

1. Install Flutter SDK.
2. From project root run:
   - `flutter pub get`
   - `flutter run`

## Notes for Assessment

- App is designed to stay fully usable offline for local features.
- Sharing is disabled when offline and gives clear user feedback.
- Camera/photo permissions are declared in Android/iOS project files.
