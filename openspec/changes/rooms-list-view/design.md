## Context

The Rooms tab exists with scaffolded RIB architecture (RoomsView, RoomsPresenter, RoomsInteractor, RoomsRouter) but displays only placeholder text. The data layer is complete - `RoomManager` with `RoomRepository` and `Room` domain model are production-ready and tested. The project uses a RIB-inspired architecture where Views are pure UI, Presenters bridge View ↔ Interactor/Router, and business logic lives in Services.

**Constraints:**
- Swift 6.0, iOS 26+ deployment target
- FulhamKit design system mandatory
- SwiftUI declarative patterns (no `@StateObject`, use `@Observable`)
- RIB architecture: View → Presenter → Interactor → Service pattern
- Everything must be `@MainActor`
- One type per file, access control defaults to `private`

**Current State:**
- `RoomManager.fetchAll() throws -> [Room]` exists and is tested
- `Room` domain model has: `id`, `name`, `kind` (RoomType enum), `customIcon`, `createdAt`
- RoomsInteractor protocol is defined but has no methods
- RoomsPresenter is empty (only holds interactor/router)
- RoomsView shows static text

## Goals / Non-Goals

**Goals:**
- Display all rooms in a visually appealing list/grid using FulhamKit components
- Show room icon (SF Symbol from RoomType) and room name for each room
- Handle empty state when no rooms exist
- Follow iOS 26+ SwiftUI best practices (Liquid Glass if applicable)
- Wire RIB layers: View → Presenter → Interactor → RoomManager
- Support dark mode automatically via FulhamKit semantic colors

**Non-Goals:**
- Room editing or deletion (future work)
- Room detail navigation (future work)
- Room creation flow (out of scope for this change)
- Filtering or searching rooms
- Reordering rooms
- Task count display per room (data not readily available)

## Decisions

### 1. List vs Grid Layout

**Decision:** Use LazyVGrid with 2 columns for room display.

**Rationale:**
- Matches onboarding flow pattern (`OnbRoomSelectionView` uses grid)
- Room icons benefit from larger touch targets
- Grid is more visually appealing than plain list for icon-heavy content
- iOS 26+ supports advanced grid layouts efficiently

**Alternative Considered:** Plain List - rejected because less visual impact and doesn't showcase room icons as prominently.

### 2. Empty State Design

**Decision:** Center-aligned VStack with SF Symbol icon, title, and optional description.

**Rationale:**
- Consistent with iOS HIG empty state patterns
- FulhamKit typography provides proper hierarchy
- Aligns with onboarding completion screen style
- Clear call-to-action for users with no rooms

**Alternative Considered:** Inline message in navigation bar - rejected because less discoverable and doesn't guide user action.

### 3. Data Fetching Strategy

**Decision:** Fetch rooms in Presenter's `init` using synchronous `throws` pattern.

**Rationale:**
- Existing RoomManager uses synchronous `throws` (no async/await in codebase)
- Consistent with project's current concurrency model
- `@MainActor` ensures safe UI updates
- Errors can be caught and displayed in View

**Alternative Considered:** `onAppear` with `Task` - rejected because introduces async patterns not yet established in the project.

**Implementation:**
```swift
// Presenter
init(interactor: any RoomsInteractor, router: any RoomsRouter) {
    self.interactor = interactor
    self.router = router
    
    do {
        self.rooms = try interactor.fetchRooms()
    } catch {
        self.errorMessage = "Failed to load rooms"
    }
}
```

### 4. Room Card Component

**Decision:** Inline Button + FKCardView with `.fkPressable` button style.

**Rationale:**
- Matches onboarding selection pattern
- FulhamKit provides `.fkPressable` for tactile feedback
- `FKHaptics.selection()` on tap for premium feel
- Reusable pattern already established in codebase

**Alternative Considered:** Extract to separate `RoomCardView` component - rejected because adds file complexity for single-use component (YAGNI).

### 5. Room Icon Source

**Decision:** Use `RoomType.icon` property for SF Symbol name.

**Rationale:**
- `RoomType` enum already defines icon mapping
- Consistent with onboarding room selection
- SF Symbols are resolution-independent
- Custom icons (`room.customIcon`) can be added later with fallback

**Assumption:** `RoomType` has `.icon` property returning SF Symbol name (needs verification).

### 6. Error Handling

**Decision:** Display error banner at top of list if fetch fails, keep UI functional.

**Rationale:**
- Non-blocking: user can still see partial UI
- Clear feedback about what went wrong
- Allows retry via pull-to-refresh (future enhancement)

**Alternative Considered:** Modal alert - rejected because too intrusive for recoverable errors.

## Risks / Trade-offs

**[Risk]** Room data could be stale if modified from another screen  
→ **Mitigation:** Use `.onAppear` refresh in future iteration when navigation is implemented

**[Risk]** Large room lists (100+) could impact performance  
→ **Mitigation:** LazyVGrid provides lazy loading; monitor performance in testing phase

**[Risk]** Empty state might not guide users to room creation if that flow doesn't exist yet  
→ **Mitigation:** Use descriptive text that sets expectations ("Add rooms in onboarding" or similar)

**[Trade-off]** Synchronous fetch in `init` blocks presenter initialization  
→ **Acceptable:** Fetch is local SwiftData query (fast), matches existing patterns

**[Trade-off]** No skeleton loading state  
→ **Acceptable:** First version prioritizes working UI; can add polish later

## Open Questions

- **Q:** Does `RoomType` have an `.icon` property that returns SF Symbol names?  
  **Resolution:** Check `RoomType.swift` implementation during task execution

- **Q:** Should rooms be sorted by creation date, name, or user-defined order?  
  **Assumption:** Sort by `createdAt` descending (newest first) until user preferences exist

- **Q:** What should empty state text say if room creation isn't implemented yet?  
  **Assumption:** Use generic "No rooms yet" message; refine when creation flow exists
