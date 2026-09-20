## ADDED Requirements

### Requirement: Rooms tab displays room list

The Rooms tab SHALL display all user rooms in a visual list interface.

#### Scenario: View all rooms UI implementation
- **WHEN** user navigates to Rooms tab
- **THEN** system displays RoomsView with room list UI
- **THEN** UI follows FulhamKit design system
- **THEN** UI uses LazyVGrid layout for rooms

#### Scenario: Room list populated from SwiftData
- **WHEN** RoomsView is initialized
- **THEN** system fetches rooms via RoomsInteractor.fetchRooms()
- **THEN** system displays all fetched rooms in grid
- **THEN** each room shows icon and name

### Requirement: RoomsInteractor provides room fetching

RoomsInteractor protocol SHALL define fetchRooms() method for retrieving all rooms.

#### Scenario: Interactor method defined
- **WHEN** RoomsInteractor protocol is implemented
- **THEN** protocol includes fetchRooms() throws -> [Room] method
- **THEN** CoreInteractor implements RoomsInteractor conformance
- **THEN** implementation delegates to RoomManager

#### Scenario: Fetch rooms via interactor
- **WHEN** presenter calls interactor.fetchRooms()
- **THEN** interactor calls RoomManager.fetchAll()
- **THEN** interactor returns array of Room domain models
- **THEN** presenter receives rooms for view display
