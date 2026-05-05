# Proposal: Custom Task Addition in Onboarding

## Summary

Implement the task selection step in onboarding flow, allowing users to:
1. Select from predefined suggested tasks for each room (with default frequency/duration)
2. **Add custom tasks** with name and frequency picker
3. Toggle tasks on/off with visual feedback
4. Remove custom tasks before completing onboarding

This completes the onboarding flow as specified in SPEC.md (lines 228-236, 400-408).

## Problem Statement

Currently, `OnbTaskSelectionView` is a placeholder showing only "Task Selection View" text. The onboarding flow needs:

1. **Task selection UI** displaying suggested tasks per room type from SPEC.md
2. **Custom task creation** allowing users to add room-specific tasks not in the predefined list
3. **State management** to pass selected rooms from RoomSelection → TaskSelection
4. **Persistence** to save rooms and their selected tasks when user proceeds

Without this, users cannot configure their cleaning tasks during onboarding, making the app non-functional.

## Proposed Solution

### Architecture Changes

**1. Create OnboardingSessionManager**
```swift
// New file: Models/Services/OnboardingSessionManager.swift
@MainActor
@Observable
final class OnboardingSessionManager {
    var selectedRooms: Set<RoomIcon> = []
    var pendingTasks: [PendingTask] = []
}
```

This follows the existing pattern where:
- **Manager** = stateful reference type holding session data
- Registered in DI container (same lifetime as `OnboardingState`)
- Shared across all onboarding screens via `OnboardingInteractor`

**2. Create PendingTask Model**
```swift
// New file: Models/Domain/PendingTask.swift
struct PendingTask: Identifiable, Equatable {
    let id: UUID
    var name: String
    var roomIcon: RoomIcon
    var frequency: Frequency
    var estimatedDuration: TaskDuration
    var isCustom: Bool
    var isSelected: Bool
}
```

Temporary struct used during onboarding before rooms exist in the database.

**3. Create SuggestedTasks Data Source**
```swift
// New file: Models/Domain/SuggestedTasks.swift
enum SuggestedTasks {
    static func tasks(for roomIcon: RoomIcon) -> [PendingTask]
}
```

Implements predefined task sets from SPEC.md table (lines 400-408):
- Kuchnia: Odkurzanie, Mycie podłogi, Czyszczenie blatu, Mycie zlewu, Mycie piekarnika
- Łazienka: Mycie toalety, Mycie umywalki, Mycie prysznica/wanny, Mycie podłogi
- Salon: Odkurzanie, Mycie podłogi, Ścieranie kurzu
- Sypialnia: Odkurzanie, Zmiana pościeli, Wietrzenie
- Korytarz: Odkurzanie, Mycie podłogi
- Biuro: Ścieranie kurzu, Odkurzanie
- Garaż: Zamiatanie, Porządkowanie
- Pralnia: Pranie, Czyszczenie pralki

### UI Implementation

**OnbTaskSelectionView Structure:**
```
ScrollView
└── VStack
    ├── ForEach(selectedRooms)
    │   ├── Room Header (name + icon)
    │   ├── [+ Dodaj zadanie] Button
    │   └── FKCardView (glass background)
    │       └── VStack of TaskRow
    │           ├── Checkmark (if selected)
    │           ├── Task name
    │           ├── Frequency label
    │           └── Delete button (× if custom)
    └── .safeAreaBar
        └── "Dalej" Button (.glassProminent)
```

**Add Custom Task Sheet:**
```
VStack
├── TextField("Nazwa zadania")
├── Picker("Częstotliwość", selection)
│   ├── Codziennie (.daily)
│   ├── 2× w tygodniu (.timesPerWeek(2))
│   ├── 3× w tygodniu (.timesPerWeek(3))
│   ├── 1× w tygodniu (.timesPerWeek(1))
│   ├── 1× w miesiącu (.monthly)
│   └── 1× na 2 tygodnie (.everyOtherWeek)
├── Spacer
└── HStack
    ├── "Anuluj" Button
    └── "Dodaj" Button (.glassProminent)
```

### User Flow

1. User arrives from RoomSelection with `selectedRooms` stored in `OnboardingSessionManager`
2. View loads suggested tasks for each selected room (auto-selected by default per SPEC.md)
3. User can:
   - **Toggle** suggested tasks on/off (tap task row)
   - **Add custom task**: Tap [+ Dodaj zadanie] → Sheet opens
     - Enter task name
     - Select frequency from picker
     - Default duration: 15 minutes (editable later in main app)
   - **Delete custom task**: Tap × button (only visible for custom tasks)
4. Tap "Dalej" → **Persistence happens**:
   - Create and save `Room` entities from `selectedRooms`
   - Create and save `RoomTask` entities from selected `pendingTasks`
   - Navigate to `OnbNotificationView`

### Data Flow

```
OnbRoomSelectionPresenter
└── onNextButtonPressed()
    └── sessionManager.selectedRooms = selectedRooms
    └── router.showOnboardingTaskSelectionView()

OnbTaskSelectionPresenter
├── init
│   └── Load suggested tasks from SuggestedTasks.tasks(for: room)
│       for each room in sessionManager.selectedRooms
├── onToggleTask(task)
│   └── Update task.isSelected in pendingTasks
├── onAddCustomTask(roomIcon, name, frequency)
│   └── Create new PendingTask(isCustom: true)
│       → Add to pendingTasks
├── onDeleteCustomTask(task)
│   └── Remove from pendingTasks
└── onNextButtonPressed()
    ├── Call interactor.saveRoomsAndTasks(
    │     rooms: sessionManager.selectedRooms,
    │     tasks: pendingTasks.filter { $0.isSelected }
    │   )
    └── router.showOnboardingNotificationView()

OnboardingInteractor
└── saveRoomsAndTasks(rooms, tasks)
    ├── For each room: create Room → roomManager.save()
    ├── For each task: create RoomTask → roomTaskManager.save()
    └── Clear sessionManager (optional)
```

### Liquid Glass Styling (iOS 26+)

Following existing patterns from `OnbRoomSelectionView`:

```swift
// Room section card
FKCardView(showBorder: false) {
    VStack {
        // tasks
    }
    .padding(.vertical, FKSpacing.medium)
}
.fkBorder(
    cornerRadius: FKRadius.medium,
    lineWidth: FKBorder.thin,
    color: Color(FKColor.Separator.default)
)

// Task row
HStack {
    Image(systemName: task.isSelected ? "checkmark.circle.fill" : "circle")
    Text(task.name)
    Spacer()
    Text(task.frequency.displayText)
    if task.isCustom {
        Button(action: onDelete) {
            Image(systemName: "xmark.circle.fill")
        }
    }
}
.padding()
.fkBorder(
    cornerRadius: FKRadius.small,
    lineWidth: task.isSelected ? FKBorder.medium : FKBorder.thin,
    color: task.isSelected ? .accentColor : Color(FKColor.Separator.default)
)
.animation(.interactiveSpring, value: task.isSelected)
.buttonStyle(.fkPressable)

// [+ Dodaj] button
Button("+ Dodaj zadanie") { }
    .font(FKTypography.secondaryLabel)
    .buttonStyle(.fkPressable)

// "Dalej" button
.buttonStyle(.glassProminent)
```

## Scope

### In Scope
- ✅ Create `OnboardingSessionManager` for state sharing
- ✅ Create `PendingTask` domain model
- ✅ Create `SuggestedTasks` with predefined task sets from SPEC.md
- ✅ Implement full `OnbTaskSelectionView` UI
- ✅ Implement `OnbTaskSelectionPresenter` logic
- ✅ Add custom task creation sheet with name + frequency picker
- ✅ Toggle suggested tasks on/off
- ✅ Delete custom tasks
- ✅ Extend `OnboardingInteractor` with save methods
- ✅ Modify `OnbRoomSelectionPresenter` to use session manager
- ✅ Register session manager in `Dependencies.swift`
- ✅ Add `Frequency.displayText` extension for UI labels

### Out of Scope
- ❌ Editing task duration during onboarding (defaults to 15 min per SPEC.md line 230)
- ❌ Editing suggested task names/frequency (toggle only per SPEC.md)
- ❌ Reordering tasks
- ❌ Task icons/colors
- ❌ "Skip all tasks" option (not in SPEC.md)
- ❌ Task search/filter

### Future Considerations
- Duration picker in add custom task sheet (quick to add if needed)
- Bulk select/deselect all tasks per room
- Task templates/categories beyond room types

## Files to Create

1. `CleaningApp/Models/Services/OnboardingSessionManager.swift`
2. `CleaningApp/Models/Domain/PendingTask.swift`
3. `CleaningApp/Models/Domain/SuggestedTasks.swift`
4. `CleaningApp/Components/Extensions/Frequency+Display.swift`

## Files to Modify

1. `CleaningApp/Onboarding/TaskSelection/OnbTaskSelectionView.swift` - Implement full UI
2. `CleaningApp/Onboarding/TaskSelection/OnbTaskSelectionPresenter.swift` - Implement logic
3. `CleaningApp/Onboarding/RoomSelection/OnbRoomSelectionPresenter.swift` - Use session manager
4. `CleaningApp/Onboarding/RIB/OnboardingInteractor.swift` - Add session manager & save methods
5. `CleaningApp/Root/Dependencies.swift` - Register `OnboardingSessionManager`

## Success Criteria

1. ✅ User can see suggested tasks for each selected room
2. ✅ User can toggle suggested tasks on/off with visual feedback
3. ✅ User can add custom tasks with name and frequency
4. ✅ User can delete custom tasks (but not suggested ones)
5. ✅ Custom tasks appear identical to suggested tasks (except × button)
6. ✅ Tapping "Dalej" creates rooms and saves selected tasks to SwiftData
7. ✅ Navigation proceeds to notification view after successful save
8. ✅ All predefined tasks match SPEC.md table (lines 400-408)
9. ✅ UI follows existing Liquid Glass patterns from `OnbRoomSelectionView`
10. ✅ No crashes when switching between rooms with different task counts

## Technical Notes

### Default Values
Per SPEC.md line 230: tasks use default values during onboarding
- **Duration**: All tasks default to appropriate values from SPEC.md table
- **Selection**: All suggested tasks start **selected** (checkbox filled)
- **Custom tasks**: Default to `.timesPerWeek(1)` and `.fifteenMinutes`

### Error Handling
- If save fails: Show alert, don't navigate
- If no rooms selected: Should be prevented by RoomSelection screen (Next button disabled)
- If no tasks selected: Allow (user can add tasks later in main app per SPEC.md)

### Performance
- Suggested tasks loaded once on init
- No heavy computation in view body
- Task list should handle 50+ tasks per room smoothly

### Accessibility
- All interactive elements are `Button` for VoiceOver support
- Task names support Dynamic Type
- Checkmarks use SF Symbols for clarity

## Dependencies

- FulhamKit (existing) - glass styling, spacing, typography
- NavigationKit (existing) - routing
- SwiftData (existing) - persistence
- `RoomManager` (existing)
- `RoomTaskManager` (existing)

## Testing Strategy

### Unit Tests (Swift Testing)
- `SuggestedTasks.tasks(for:)` returns correct tasks for each room type
- `OnbTaskSelectionPresenter.onToggleTask` updates selection state
- `OnbTaskSelectionPresenter.onAddCustomTask` creates task with correct properties
- `OnbTaskSelectionPresenter.onDeleteCustomTask` removes only custom tasks
- `OnboardingSessionManager` properly shares state

### Integration Tests
- Full flow: RoomSelection → TaskSelection → save → navigation
- Custom task creation → toggle → delete
- Save with mixed suggested + custom tasks

### Manual Testing
- Visual verification of Liquid Glass styling
- Dynamic Type scaling
- VoiceOver navigation
- Light/Dark mode

## Open Questions

None - all design decisions resolved during exploration phase.

## Timeline Estimate

- **Small (1-2 days)**
  - Most architecture patterns already established
  - UI follows existing RoomSelection patterns
  - No complex business logic
  - Straightforward CRUD operations

## References

- SPEC.md lines 228-236: Onboarding task selection requirements
- SPEC.md lines 400-408: Predefined task sets per room
- Existing `OnbRoomSelectionView.swift`: UI patterns to follow
- Existing `RoomManager`/`RoomTaskManager`: Service patterns to use
