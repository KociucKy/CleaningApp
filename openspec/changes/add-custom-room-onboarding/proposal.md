## Why

Users are limited to predefined room types during onboarding, which doesn't accommodate unique spaces in their homes (e.g., "Conservatory", "Gym", "Pantry"). The "Custom" room type exists but has no suggested tasks, making it unusable. We need to enable custom room creation during onboarding while replacing "Custom" with a real room type that has meaningful suggested tasks.

## What Changes

- Add "+" toolbar button in `OnbRoomSelectionView` that opens a bottom sheet for creating custom rooms
- Create custom room creation UI with name input and optional icon selection
- Replace "Custom" `RoomType` enum case with a new predefined room type that has suggested tasks (e.g., "Dining Room")
- Update `OnboardingFlowState` to track user-created custom rooms separately from predefined selections
- Extend `Room` domain model to support custom room types with user-defined names and icons
- Update onboarding save logic to persist both predefined and custom rooms

## Capabilities

### New Capabilities
- `custom-room-creation`: Allow users to create custom rooms with custom names and optional icon selection during onboarding

### Modified Capabilities
- `onboarding`: Add custom room creation step/flow within room selection
- `room-management`: Extend room model to distinguish between predefined and custom room types

## Impact

**Affected Files**:
- `CleaningApp/Onboarding/RoomSelection/OnbRoomSelectionView.swift` - Add toolbar button and sheet presentation
- `CleaningApp/Onboarding/RoomSelection/OnbRoomSelectionPresenter.swift` - Handle custom room creation actions
- `CleaningApp/Onboarding/OnboardingFlowState.swift` - Track custom rooms
- `CleaningApp/Onboarding/RIB/OnboardingInteractor.swift` - Custom room persistence logic
- `CleaningApp/Models/Domain/RoomType.swift` - Replace `.custom` with new predefined type
- `CleaningApp/Models/Domain/RoomType+SuggestedTasks.swift` - Add tasks for new room type, remove custom case
- `CleaningApp/Models/Domain/Room.swift` - Add support for custom room types

**New Files**:
- Custom room creation view and presenter components
- Custom room input form component

**Data Model Changes**:
- `RoomType` enum: Replace `.custom` case with new predefined type (e.g., `.diningRoom`)
- `Room` struct: Add optional `customName` and `customIcon` fields to support user-created rooms

**User Experience**:
- Users can now create unlimited custom rooms during onboarding
- Custom rooms can have any name and icon
- New predefined room type provides better out-of-box experience
