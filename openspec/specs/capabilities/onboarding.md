# Capability: Onboarding

**Status**: Implemented  
**Last Updated**: 2026-04-25

---

## Overview

**Onboarding** is the first-time user experience that guides new users through setting up their home cleaning system. It collects room selections, task preferences, and optional settings like notifications and paywall.

The flow creates a personalized starting point so users don't face an empty app.

---

## User Flow

```
┌──────────────┐
│   Welcome    │  "Welcome to CleaningApp"
│    Screen    │  → Get Started button
└──────┬───────┘
       │
       ▼
┌──────────────┐
│Room Selection│  Select room types (Kitchen, Bedroom, etc.)
│              │  → Can select multiple
│              │  → Skip button available
└──────┬───────┘
       │
       ▼
┌──────────────┐
│Task Selection│  For each selected room:
│   (Per Room) │  → See suggested tasks
│              │  → First 3 auto-selected
│              │  → Can toggle on/off
└──────┬───────┘
       │
       ▼
┌──────────────┐
│Notifications │  Request notification permissions
│   (Optional) │  → User can allow/skip
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Paywall    │  Premium features pitch
│   (Optional) │  → Subscribe or continue free
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Completed   │  "You're all set!"
│              │  → Navigate to main app
└──────────────┘
```

**Key characteristic**: Linear flow - no going back, moves forward only.

---

## Steps Breakdown

### 1. Welcome Screen

**Purpose**: Introduce the app and motivate the user.

**UI**:
- Welcome message
- Brief value proposition
- "Get Started" button

**Actions**:
- `onGetStartedPressed()` → Navigate to Room Selection

**State**: No data collected at this step.

---

### 2. Room Selection

**Purpose**: Let users choose which rooms they want to track.

**UI**:
- Grid of room type cards (10 options)
- Each card shows:
  - Room icon (SF Symbol)
  - Localized room name
  - Selection state (visual indicator)
- "Clear" button (if any selected)
- "Next" button (enabled if ≥1 room selected)
- "Skip" button (skip to notifications)

**Interaction**:
- Tap card → Toggle selection
- Cards animate in on entrance (staggered spring animation)
- Selection count updates dynamically

**Business Logic**:
```swift
func toggleRoom(_ room: RoomType) {
    if room is selected:
        - Remove from selectedRooms
        - Remove all tasks for that room
    else:
        - Add to selectedRooms
        - Auto-select first 3 suggested tasks
}
```

**Default behavior**: First 3 tasks auto-selected for new room.

**Validation**:
- "Next" button disabled if no rooms selected
- No maximum room limit

**Actions**:
- `onNextButtonPressed()` → Navigate to Task Selection
- `onSkipButtonPressed()` → Navigate to Notifications (loses all room data)
- `onClearButtonPressed()` → Deselect all rooms
- `onRoomCardPressed(room)` → Toggle room selection

---

### 3. Task Selection

**Purpose**: Let users choose which tasks to track for each selected room.

**UI Structure** (per room):
- Room header (name + icon)
- List of suggested tasks for that room
- Each task shows:
  - Task name (localized)
  - Frequency (e.g., "Daily", "2x per week")
  - Estimated duration (e.g., "5 min")
  - Selection state (toggle/checkbox)

**Interaction**:
- Tap task → Toggle selection
- Can select 0 tasks (room with no tasks is valid)
- Can select all tasks

**Business Logic**:
```swift
func toggleTask(_ task: RoomTask, for room: RoomType) {
    if task is selected:
        - Remove from selectedTasks[room]
    else:
        - Add to selectedTasks[room]
}
```

**Validation**:
- Can proceed with 0 tasks selected (edge case: user selected rooms but no tasks)
- Tasks use stable hardcoded UUIDs for identity

**Navigation**:
- Typically iterates through each selected room
- After all rooms → Navigate to Notifications

---

### 4. Notifications (Optional)

**Purpose**: Request permission for push notifications.

**UI**:
- Explanation of notification value
- "Enable Notifications" button
- "Skip" or "Maybe Later" option

**System Integration**:
- Triggers iOS notification permission dialog
- Honors user choice (no repeated asks)

**State**: Permission status likely stored but not part of OnboardingFlowState.

**Navigation**:
- After interaction → Navigate to Paywall (or skip to Completed)

---

### 5. Paywall (Optional)

**Purpose**: Offer premium subscription.

**UI**:
- Premium feature list
- Pricing tiers
- "Subscribe" button
- "Continue Free" option

**Business Logic**:
- Likely integrated with StoreKit
- Not blocking - users can continue free

**State**: Subscription status separate from onboarding.

**Navigation**:
- After interaction → Navigate to Completed

---

### 6. Onboarding Completed

**Purpose**: Celebrate setup completion and transition to main app.

**UI**:
- Success message
- Summary of setup (X rooms, Y tasks)
- "Start Cleaning" or "Go to App" button

**Critical Action**: `saveAndCompleteOnboarding()`

```swift
func saveAndCompleteOnboarding() {
    // 1. Save all selected rooms to SwiftData
    for roomType in selectedRooms {
        let room = Room(name: roomType.rawValue, kind: roomType)
        try roomManager.save(room)
    }
    
    // 2. Save all selected tasks
    for room in savedRooms {
        for task in selectedTasks[room.kind] {
            task.roomId = room.id  // Replace placeholder
            try roomTaskManager.save(task)
        }
    }
    
    // 3. Mark onboarding complete
    appState.updateViewState(showOnboarding: false)
}
```

**Failure Handling**:
> "Data loss is preferable to leaving the user stuck in onboarding."

If save fails, onboarding still completes (user sees empty app but can add rooms manually).

**Navigation**:
- After completion → Navigate to Main App (Home tab)

---

## State Management

### OnboardingFlowState

**Purpose**: Single source of truth for onboarding selections.

**Properties**:
```swift
@Observable
final class OnboardingFlowState {
    private(set) var selectedRooms: [RoomType]           // Ordered list
    private(set) var selectedTasks: [RoomType: [RoomTask]]  // Per-room tasks
}
```

**Lifecycle**:
- Created at onboarding start
- Lives for entire onboarding flow
- Cleared/disposed after completion

**Operations**:
- `toggleRoom(_)` - Add/remove room
- `clearRooms()` - Deselect all
- `isRoomSelected(_)` - Check selection state
- `toggleTask(_, for:)` - Add/remove task
- `isTaskSelected(_, for:)` - Check task state
- `selectedTasks(for:)` - Get tasks for room

---

## Persistence Strategy

### Transactional Save

**Order matters**:
1. Save rooms first (generates IDs)
2. Save tasks second (requires room IDs)

**Room ID substitution**:
- Suggested tasks have placeholder `roomId`
- Real `roomId` assigned at save time

**No rollback**:
- If task save fails, rooms remain saved
- Partial success is acceptable
- User can manually add tasks later

---

## Business Rules

### Validation Rules
1. Must select ≥1 room to proceed past Room Selection
2. Can select 0 tasks for a room (edge case)
3. Can skip room selection entirely (loses all data)
4. Cannot go backward in flow

### Default Behavior
1. First 3 tasks auto-selected when room is selected
2. Room name defaults to `RoomType.rawValue` (e.g., "Kitchen")
3. Task IDs are stable (hardcoded UUIDs)

### Edge Cases
1. **Select room, then deselect**: Tasks for that room are cleared
2. **Skip room selection**: Jumps to Notifications, loses all data
3. **Save failure**: Onboarding completes anyway, user sees empty app
4. **0 tasks selected**: Valid, user can add tasks later

---

## Design Decisions

### Why Linear Flow?
- Simplicity: Users know where they are, what's next
- Momentum: Keeps users moving forward
- Mobile-friendly: No complex navigation

**Trade-off**: Can't go back to change room selection after moving forward.

### Why Auto-Select First 3 Tasks?
- Reduces decision fatigue
- Provides sensible defaults
- Users can deselect if desired

**Trade-off**: Users might not realize they can customize.

### Why Allow 0 Tasks?
- User agency: Some users want minimal tracking
- Flexibility: Can add tasks later
- Avoids blocking UI

**Trade-off**: User might end up with empty rooms.

### Why Graceful Save Failure?
- User experience: Don't trap user in onboarding
- Recovery: User can manually add rooms/tasks
- Pragmatic: Rare failure case

**Trade-off**: Silent data loss (no error shown to user).

---

## Missing Features

1. **Progress Indicator**: No step counter (e.g., "Step 2 of 5")
2. **Back Button**: Can't return to previous step
3. **Edit After Completion**: Can't restart onboarding
4. **Preview**: No summary before save
5. **Custom Room Names**: Rooms use `RoomType.rawValue`, can't customize during onboarding
6. **Task Customization**: Can't edit task frequency/duration during onboarding

---

## Open Questions

1. **Re-onboarding**: Should users be able to reset and redo onboarding?
2. **Progress Saving**: Should partial progress be saved (e.g., survive app kill)?
3. **Validation**: Should we prevent 0-task rooms? Or show a warning?
4. **Naming**: Should users customize room names during onboarding?
5. **Task Editing**: Should users be able to edit task details during onboarding?
6. **Skip vs. Continue**: What's the difference between "Skip" and continuing with 0 selections?
7. **Analytics**: Should we track completion rate, drop-off points, common selections?

---

## Implementation References

- Flow state: `Onboarding/OnboardingFlowState.swift`
- Interactor: `Onboarding/RIB/OnboardingInteractor.swift`
- Router: `Onboarding/RIB/OnboardingRouter.swift`
- Steps:
  - Welcome: `Onboarding/Welcome/`
  - Room Selection: `Onboarding/RoomSelection/`
  - Task Selection: `Onboarding/TaskSelection/`
  - Notifications: `Onboarding/Notifications/`
  - Paywall: `Onboarding/Paywall/`
  - Completed: `Onboarding/Completed/`
