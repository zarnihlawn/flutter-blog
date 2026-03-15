# 7CC012 Coursework Support Report

## App Summary

This application is an offline-first mobile blog client built with Flutter. It provides local message management using SQLite and allows image attachments from camera/gallery. It supports social sharing of individual posts and includes connectivity-aware behavior with clear failure handling.

## LO Coverage

- LO1: Mobile app development demonstrated through complete Flutter application architecture and implementation.
- LO2: UI/UX demonstrated through multi-screen flow, custom Brutalist visual language, and animation transitions.
- LO3: Connectivity handling demonstrated via online/offline detection, guarded share flow, and exception-aware operation.

## Functional Criteria Checklist

- [x] Accept text input for a message.
- [x] Create, edit, view, and delete single messages.
- [x] View message list and individual message detail.
- [x] Search messages and show matching results.
- [x] Select and delete a group of messages.
- [x] Store messages in SQLite local database.
- [x] Attach image from gallery.
- [x] Attach image from camera.
- [x] Share individual text/image message to online social app account.

## Connectivity and Error Handling

- Connectivity status is monitored with `connectivity_plus`.
- Offline state is shown through a persistent status banner.
- Share attempts while offline are blocked with user feedback.
- Missing image file edge case is handled with fallback UI.
- Database load and save actions are wrapped with state and error messages.

## Architecture Overview

- `models/message.dart`: Message domain model.
- `data/database_service.dart`: SQLite connection and schema.
- `data/message_repository.dart`: Data access layer and CRUD/search operations.
- `state/message_controller.dart`: App state, selection logic, media pickers, share behavior.
- `screens/*`: Home, detail, and editor screens.
- `widgets/message_card.dart`: Reusable Brutalist card with animated selection states.
- `theme/brutal_theme.dart`: Global Brutalist design tokens and component themes.

## Test and Verification

### Automated

- `flutter analyze` (no issues).
- `flutter test` (passes theme test).

### Manual Test Matrix

- [ ] Create message without image.
- [ ] Create message with gallery image.
- [ ] Create message with camera image.
- [ ] Edit message text.
- [ ] Replace/remove existing image.
- [ ] Delete single message.
- [ ] Select multiple and delete.
- [ ] Search none/one/many result(s).
- [ ] Share text-only message.
- [ ] Share image message.
- [ ] Attempt share while offline.

## 4-5 Minute Demo Script

1. Open app and show online/offline status banner.
2. Create a message with text only and show list update.
3. Open detail page, then edit message.
4. Add image from gallery or camera and save.
5. Show search with highlighted keyword matches.
6. Enter multi-select mode, select multiple posts, perform bulk delete.
7. Open one post and share to a social app account.
8. Briefly show offline behavior and guarded sharing.

## Third-Party Libraries

- provider
- sqflite
- path
- image_picker
- share_plus
- connectivity_plus
- intl

These libraries are used only for legitimate app functionality and are listed for transparency.
