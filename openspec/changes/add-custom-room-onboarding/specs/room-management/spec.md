## ADDED Requirements

### Requirement: Room domain model supports custom rooms

The `Room` domain model SHALL support custom rooms with user-defined names and icons.

#### Scenario: Room has isCustom flag
- **WHEN** a room is created
- **THEN** system stores an `isCustom: Bool` field indicating whether the room is custom or predefined

#### Scenario: Custom rooms store custom icon
- **WHEN** a custom room is created with a user-selected icon
- **THEN** system stores the SF Symbol name in an optional `customIcon: String?` field

#### Scenario: Predefined rooms use default icon behavior
- **WHEN** a predefined room is created (isCustom = false)
- **THEN** system leaves `customIcon` as nil and derives icon from `RoomType.symbolName`

### Requirement: RoomType enum supports custom rooms

The `RoomType` enum SHALL include a sentinel case for custom rooms.

#### Scenario: customRoom case exists
- **WHEN** a custom room is created
- **THEN** system assigns `kind = .customRoom` to distinguish it from predefined types

#### Scenario: customRoom not shown in selection grid
- **WHEN** room selection grid is rendered
- **THEN** system filters out `.customRoom` from `RoomType.allCases` (only show 9 predefined types)

### Requirement: RoomType includes diningRoom

The `RoomType` enum SHALL include `.diningRoom` as a new predefined room type.

#### Scenario: diningRoom available in selection
- **WHEN** user views room selection screen
- **THEN** system displays Dining Room as one of the 9 predefined room options

#### Scenario: diningRoom has suggested tasks
- **WHEN** user selects Dining Room
- **THEN** system provides 4-5 suggested tasks (e.g., "Set table", "Clear table", "Wipe table", "Vacuum floor")

### Requirement: RoomEntity persists custom room fields

The `RoomEntity` SwiftData model SHALL persist custom room fields.

#### Scenario: isCustom field persisted
- **WHEN** a room is saved to SwiftData
- **THEN** system stores the `isCustom` boolean value in the entity

#### Scenario: customIcon field persisted
- **WHEN** a custom room with an icon is saved
- **THEN** system stores the SF Symbol name string in the entity's `customIcon` field

#### Scenario: Backward compatibility maintained
- **WHEN** existing room entities (created before this change) are loaded
- **THEN** system defaults `isCustom = false` and `customIcon = nil`

### Requirement: Room mapper handles custom rooms

The `RoomMapper` SHALL correctly map custom rooms between domain and entity models.

#### Scenario: Custom room mapped to entity
- **WHEN** a custom `Room` (isCustom = true) is converted to `RoomEntity`
- **THEN** system sets `icon = "customRoom"` and stores user-provided icon in `customIcon` field

#### Scenario: Custom room mapped from entity
- **WHEN** a `RoomEntity` with `icon = "customRoom"` is converted to `Room`
- **THEN** system sets `kind = .customRoom`, `isCustom = true`, and copies `customIcon` value

## REMOVED Requirements

### Requirement: RoomType includes custom case

**Reason**: The `.custom` case has been removed because it had no suggested tasks and was not useful. It is replaced by `.diningRoom` (a real predefined type) and `.customRoom` (a sentinel for user-created rooms).

**Migration**: Existing code using `.custom` should be updated to use `.diningRoom` for predefined selections or `.customRoom` for custom room logic. No data migration needed as `.custom` was never persisted.
