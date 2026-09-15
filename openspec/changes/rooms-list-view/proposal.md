## Why

The Rooms tab currently shows only a placeholder text. Users need to see their created rooms to manage them and understand what spaces they're tracking in the app. This is a foundational feature blocking the full room management experience.

## What Changes

- Display all rooms in RoomsView using SwiftData via RoomManager
- Implement modern iOS 26+ SwiftUI UI using FulhamKit design system
- Add room list with visual room type icons and names
- Handle empty state when no rooms exist
- Connect RoomsPresenter to RoomsInteractor for data fetching
- Follow established RIB architecture pattern

## Capabilities

### New Capabilities
- `rooms-list-display`: Display list of all user rooms with icons, names, and proper empty state handling using FulhamKit components and iOS 26+ SwiftUI patterns

### Modified Capabilities
- `room-management`: Implementing the "View All Rooms" user capability which was previously specified but not implemented in the UI

## Impact

- `CleaningApp/Core/Rooms/Presentation/RoomsView.swift` - Complete rewrite to display room list
- `CleaningApp/Core/Rooms/Presentation/RoomsPresenter.swift` - Add state and data fetching logic
- `CleaningApp/Core/Rooms/RIB/RoomsInteractor.swift` - Add room fetching protocol method
- `CleaningApp/Root/RIB/CoreInteractor.swift` - Implement RoomsInteractor conformance
- Uses existing `RoomManager` and `Room` domain model (no changes needed)
