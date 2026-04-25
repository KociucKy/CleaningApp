## 1. Domain Model Changes

- [ ] 1.1 Add `isCustom: Bool` field to `Room` struct in `Models/Domain/Room.swift`
- [ ] 1.2 Add `customIcon: String?` field to `Room` struct
- [ ] 1.3 Update `Room` init to include new fields with defaults (`isCustom = false`, `customIcon = nil`)
- [ ] 1.4 Replace `.custom` case with `.diningRoom` in `RoomType` enum in `Models/Domain/RoomType.swift`
- [ ] 1.5 Add `.customRoom` sentinel case to `RoomType` enum
- [ ] 1.6 Add `diningRoom` localized name in `RoomType.localizedName` computed property
- [ ] 1.7 Add `diningRoom` SF Symbol (`fork.knife.circle` or `table.furniture`) in `RoomType.symbolName`
- [ ] 1.8 Add `.customRoom` to `localizedName` and `symbolName` (fallback values, never shown in UI)

## 2. Suggested Tasks for Dining Room

- [ ] 2.1 Remove `.custom` case from `RoomType+SuggestedTasks.swift`
- [ ] 2.2 Add `.diningRoom` case to `suggestedTasks` computed property
- [ ] 2.3 Define 4-5 tasks for dining room (set table, clear table, wipe table, vacuum floor, dust shelves)
- [ ] 2.4 Assign stable UUIDs for dining room tasks (e.g., `DA000000-0000-0000-0000-000000000001`)
- [ ] 2.5 Add `.customRoom` case returning empty array (`[]`)

## 3. Persistence Layer Updates

- [ ] 3.1 Add `isCustom: Bool` field to `RoomEntity` in `Models/Entities/RoomEntity.swift`
- [ ] 3.2 Add `customIcon: String?` field to `RoomEntity`
- [ ] 3.3 Update `RoomEntity` init to include new fields
- [ ] 3.4 Update `RoomMapper.toDomain()` to map `isCustom` and `customIcon` fields
- [ ] 3.5 Update `RoomMapper.toEntity()` to handle custom rooms (map `.customRoom` kind, store `customIcon`)
- [ ] 3.6 Test SwiftData schema migration (existing rooms default to `isCustom = false`)

## 4. Onboarding Flow State Updates

- [ ] 4.1 Create `CustomRoomSelection` struct in `Onboarding/OnboardingFlowState.swift` with `id`, `name`, `icon` properties
- [ ] 4.2 Add `customRooms: [CustomRoomSelection]` array to `OnboardingFlowState`
- [ ] 4.3 Add `addCustomRoom(_:)` method to append to `customRooms` array
- [ ] 4.4 Add `removeCustomRoom(id:)` method to remove custom room by UUID
- [ ] 4.5 Add `isCustomRoomSelected(id:)` method to check custom room selection state
- [ ] 4.6 Update `clearRooms()` to also clear `customRooms` array

## 5. Custom Room Creation UI Components

- [ ] 5.1 Create `OnbCustomRoomSheetView.swift` in `Onboarding/Components/`
- [ ] 5.2 Create `OnbCustomRoomSheetPresenter.swift` in `Onboarding/Components/`
- [ ] 5.3 Implement name input step with TextField, auto-focus, character limit (30 chars)
- [ ] 5.4 Implement "Next" button (disabled if name empty)
- [ ] 5.5 Create `OnbIconPickerView.swift` component for icon selection
- [ ] 5.6 Define curated icon list (15-20 SF Symbols: `house`, `dumbbell`, `book`, `paintpalette`, `leaf`, etc.)
- [ ] 5.7 Implement icon grid with selection state
- [ ] 5.8 Add default icon fallback (`square.grid.2x2`)
- [ ] 5.9 Implement sheet dismissal on icon selection

## 6. Room Selection View Updates

- [ ] 6.1 Add `@State var showCustomRoomSheet = false` to `OnbRoomSelectionView`
- [ ] 6.2 Add `ToolbarItem` with "+" button in `.topBarTrailing` placement
- [ ] 6.3 Add `.sheet(isPresented:)` modifier presenting `OnbCustomRoomSheetView`
- [ ] 6.4 Update `ForEach` to include both `RoomType.allCases` (excluding `.customRoom`) and custom rooms
- [ ] 6.5 Render custom room cards with user-provided name and icon
- [ ] 6.6 Update `visibleCellCount` calculation to account for custom rooms (predefined count + custom count)
- [ ] 6.7 Ensure staggered animation works with dynamic room count

## 7. Room Selection Presenter Updates

- [ ] 7.1 Add `onAddCustomRoomPressed()` action to set `showCustomRoomSheet = true`
- [ ] 7.2 Add `onCustomRoomCreated(name: String, icon: String)` action
- [ ] 7.3 Call `interactor.addCustomRoom(name:icon:)` in `onCustomRoomCreated`
- [ ] 7.4 Add `onCustomRoomCardPressed(id: UUID)` action for toggling custom room selection
- [ ] 7.5 Add `isCustomRoomSelected(_ id: UUID) -> Bool` forwarding to interactor
- [ ] 7.6 Expose `customRooms` from interactor for rendering

## 8. Onboarding Interactor Updates

- [ ] 8.1 Add `func addCustomRoom(name: String, icon: String)` to `OnboardingInteractor`
- [ ] 8.2 Create `CustomRoomSelection` and call `flowState.addCustomRoom(_:)`
- [ ] 8.3 Add `func toggleCustomRoom(id: UUID)` for selection toggling
- [ ] 8.4 Add `isCustomRoomSelected(id:)` forwarding to flow state
- [ ] 8.5 Expose `customRooms` computed property from flow state
- [ ] 8.6 Update `saveAndCompleteOnboarding()` to persist custom rooms
- [ ] 8.7 Loop through `flowState.customRooms` and save as `Room(isCustom: true, kind: .customRoom, customIcon: icon)`

## 9. Localization

- [ ] 9.1 Add `"room_type.dining_room"` key to `Localizable.xcstrings`
- [ ] 9.2 Add `"onb_custom_room.sheet_title"` for sheet header
- [ ] 9.3 Add `"onb_custom_room.name_placeholder"` for text field
- [ ] 9.4 Add `"onb_custom_room.icon_title"` for icon selection header
- [ ] 9.5 Add `"onb_custom_room.button_next"` for navigation button
- [ ] 9.6 Add dining room task names (e.g., `"task.set_table"`, `"task.clear_table"`)

## 10. Testing

- [ ] 10.1 Add test for `Room` with `isCustom = true` and custom icon
- [ ] 10.2 Test `RoomMapper` correctly maps custom rooms to/from entity
- [ ] 10.3 Test `OnboardingFlowState.addCustomRoom()` appends to array
- [ ] 10.4 Test `OnboardingFlowState.customRooms` persistence through onboarding flow
- [ ] 10.5 Test `OnboardingInteractor.saveAndCompleteOnboarding()` saves custom rooms to SwiftData
- [ ] 10.6 Test mixed selection of predefined + custom rooms
- [ ] 10.7 Test custom room with empty name is rejected
- [ ] 10.8 Test custom room cards render in grid with correct styling
- [ ] 10.9 Test `.diningRoom` has suggested tasks
- [ ] 10.10 Test `.customRoom` case not shown in room selection grid

## 11. Code Quality

- [ ] 11.1 Run `swiftlint` and fix any warnings
- [ ] 11.2 Run `swiftformat .` to ensure formatting consistency
- [ ] 11.3 Add `// MARK:` comments to new sections
- [ ] 11.4 Ensure all new types follow one-type-per-file convention
- [ ] 11.5 Add accessibility labels for custom room cards
- [ ] 11.6 Test VoiceOver support for "+" button and custom room creation flow

## 12. Manual Testing

- [ ] 12.1 Test creating 1 custom room during onboarding
- [ ] 12.2 Test creating 5+ custom rooms
- [ ] 12.3 Test custom room with very long name (30+ chars)
- [ ] 12.4 Test selecting custom room icon
- [ ] 12.5 Test dismissing custom room sheet without creating room
- [ ] 12.6 Test mixed selection (2 predefined + 2 custom rooms)
- [ ] 12.7 Test completing onboarding and verify custom rooms appear in main app
- [ ] 12.8 Test custom rooms have 0 tasks after onboarding
- [ ] 12.9 Test dining room has 4-5 suggested tasks
- [ ] 12.10 Verify custom room cards match design system (borders, selection state, animations)
