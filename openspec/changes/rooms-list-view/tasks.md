## 1. RIB Layer - Interactor Protocol

- [x] 1.1 Add fetchRooms() method to RoomsInteractor protocol in RoomsInteractor.swift
- [x] 1.2 Implement RoomsInteractor.fetchRooms() in CoreInteractor extension (delegate to RoomManager.fetchAll())

## 2. Presenter - State and Data Fetching

- [x] 2.1 Add @State property `rooms: [Room] = []` to RoomsPresenter
- [x] 2.2 Add @State property `errorMessage: String?` to RoomsPresenter for error handling
- [x] 2.3 Add @State property `isLoading: Bool = true` to RoomsPresenter
- [x] 2.4 Implement room fetching in RoomsPresenter init (call interactor.fetchRooms() with error handling)
- [x] 2.5 Sort rooms by createdAt descending after fetching

## 3. View - Import Dependencies

- [x] 3.1 Add import FulhamKit to RoomsView.swift

## 4. View - Empty State UI

- [x] 4.1 Create empty state VStack with centered alignment in RoomsView body
- [x] 4.2 Add SF Symbol icon (e.g., "house") with size 48pt and FKColor.Label.secondary
- [x] 4.3 Add "No rooms yet" title using FKTypography.statValue and FKColor.Label.primary
- [x] 4.4 Add descriptive text using FKTypography.body and FKColor.Label.secondary
- [x] 4.5 Wrap empty state in conditional `if presenter.rooms.isEmpty && presenter.errorMessage == nil`

## 5. View - Room Grid Layout

- [x] 5.1 Define two-column LazyVGrid with GridItem.flexible() and FKSpacing.medium spacing
- [x] 5.2 Add LazyVGrid with ForEach over presenter.rooms inside ScrollView
- [x] 5.3 Apply horizontal padding FKSpacing.large to grid

## 6. View - Room Card Component

- [x] 6.1 Create Button for each room in ForEach
- [x] 6.2 Add FKHaptics.selection() call in button action
- [x] 6.3 Create FKCardView(showBorder: false) as button label
- [x] 6.4 Add VStack with FKSpacing.medium spacing inside card
- [x] 6.5 Add Image(systemName: room.kind.symbolName) with 32pt font size
- [x] 6.6 Handle custom icon: use room.customIcon if present, else room.kind.symbolName
- [x] 6.7 Add Text(room.name) with FKTypography.secondaryLabel
- [x] 6.8 Apply vertical padding FKSpacing.extraLarge to VStack
- [x] 6.9 Apply horizontal padding FKSpacing.default to VStack
- [x] 6.10 Add .fkBorder modifier with FKRadius.medium, FKBorder.thin, and FKColor.Separator.default
- [x] 6.11 Apply .buttonStyle(.fkPressable) to button
- [x] 6.12 Set .foregroundStyle(Color(FKColor.Label.primary)) on card content

## 7. View - Error Handling UI

- [x] 7.1 Add error banner at top of view when presenter.errorMessage is not nil
- [x] 7.2 Display error message using FKTypography.body and FKColor.Label.primary
- [x] 7.3 Style error banner with FKColor.Background.canvas background and padding

## 8. View - Navigation Configuration

- [x] 8.1 Wrap main content in conditional: if presenter.isLoading show ProgressView, else show content
- [x] 8.2 Keep existing .navigationTitle and .navigationBarTitleDisplayMode modifiers
- [x] 8.3 Ensure navigation title uses localized string key "rooms.nav_title"

## 9. Testing and Verification

- [x] 9.1 Build project with xcodegen generate and verify no compilation errors
- [x] 9.2 Run app in simulator and verify room grid displays correctly
- [x] 9.3 Test empty state by clearing all rooms from SwiftData
- [x] 9.4 Verify haptic feedback triggers on room card tap
- [x] 9.5 Test dark mode appearance using FulhamKit semantic colors
- [x] 9.6 Verify grid adapts to different screen sizes (iPhone SE to iPhone Pro Max)
