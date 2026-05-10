# Proposal: Custom Task Addition in Onboarding

## Summary

Add custom task creation functionality to the **existing** task selection screen in onboarding, allowing users to:
1. ✅ **(EXISTING)** Select from predefined suggested tasks for each room
2. ➕ **(NEW)** Add custom tasks with name + frequency picker
3. ✅ **(EXISTING)** Toggle tasks on/off with visual feedback
4. ➕ **(NEW)** Remove custom tasks before completing onboarding

This extends the completed task selection feature (on `feature/onboarding-integration` branch) with custom task creation capability.

## Problem Statement

The task selection screen (`OnbTaskSelectionView`) on `feature/onboarding-integration` branch is fully functional with:
- ✅ Suggested tasks per room type loaded from `RoomType+SuggestedTasks`
- ✅ Toggle selection with visual feedback
- ✅ Collapsible room sections with animations
- ✅ State management via `OnboardingFlowState`
- ✅ Persistence to SwiftData

However, users **cannot add custom tasks** that aren't in the predefined list. If a user wants a task like "Organize pantry" for Kitchen or "Water plants" for Living Room, they're blocked.

## Proposed Solution

### Architecture Changes

**Extend OnboardingFlowState** (existing file)
```swift
// Modify: CleaningApp/Onboarding/OnboardingFlowState.swift
@Observable
@MainActor
final class OnboardingFlowState {
    // EXISTING properties...
    private(set) var selectedRooms: [RoomType] = []
    private(set) var selectedTasks: [RoomType: [RoomTask]] = [:]
    private(set) var customRooms: [CustomRoomSelection] = []
    
    // NEW property for custom tasks
    private(set) var customTasks: [RoomType: [RoomTask]] = [:]
    
    // NEW methods
    func addCustomTask(_ task: RoomTask, for room: RoomType)
    func removeCustomTask(_ task: RoomTask, for room: RoomType)
    func allTasks(for room: RoomType) -> [RoomTask] // suggested + custom
}
```

This follows the existing pattern where `OnboardingFlowState` holds all onboarding session data.

### UI Changes

**Modify OnbTaskSelectionView** (existing collapsed room sections):
```
ScrollView
└── LazyVStack
    └── ForEach(selectedRooms)
        └── roomSection(room)
            ├── roomSectionHeader (EXISTING - collapsible)
            └── if !isCollapsed:
                ├── Divider
                ├── ForEach(suggested tasks) - EXISTING
                │   └── taskRow(task) - EXISTING
                ├── Divider
                ├── ForEach(custom tasks) - NEW
                │   └── taskRow(task, showDelete: true) - MODIFIED
                └── [+ Dodaj zadanie] Button - NEW
```

**Changes needed:**
1. Add `[+ Dodaj zadanie]` button at the bottom of each room's task list
2. Modify `taskRow` to show delete button (×) for custom tasks
3. Display custom tasks after suggested tasks in the same list
4. Custom tasks use the same visual style as suggested ones

**Add Custom Task Sheet** (NEW component):
```swift
struct OnbAddCustomTaskSheet: View {
    @Binding var isPresented: Bool
    let roomType: RoomType
    let onAdd: (RoomTask) -> Void
    
    @State private var taskName = ""
    @State private var selectedFrequency: Frequency = .timesPerWeek(1)
    
    var body: some View {
        NavigationStack {
            Form {
                Section("common.label.task_name") {
                    TextField("onb_custom_task.placeholder.task_name", text: $taskName)
                }
                Section("common.label.frequency") {
                    Picker("common.label.frequency", selection: $selectedFrequency) {
                        Text("frequency.daily").tag(Frequency.daily)
                        Text("frequency.times_per_week_2").tag(Frequency.timesPerWeek(2))
                        Text("frequency.times_per_week_3").tag(Frequency.timesPerWeek(3))
                        Text("frequency.weekly").tag(Frequency.timesPerWeek(1))
                        Text("frequency.every_other_week").tag(Frequency.everyOtherWeek)
                        Text("frequency.monthly").tag(Frequency.monthly)
                    }
                }
            }
            .navigationTitle("onb_custom_task.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.action.cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.action.add") {
                        let task = RoomTask(
                            name: taskName,
                            roomId: UUID(), // placeholder
                            frequency: selectedFrequency,
                            estimatedDuration: .fifteenMinutes
                        )
                        onAdd(task)
                        isPresented = false
                    }
                    .disabled(taskName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
```

### User Flow

1. User arrives at TaskSelection with suggested tasks already displayed (EXISTING)
2. User can toggle suggested tasks on/off by tapping (EXISTING)
3. **NEW:** User taps [+ Dodaj zadanie] button at bottom of a room section
4. **NEW:** Sheet opens with:
   - TextField for task name
   - Picker for frequency (6 common options)
   - Duration defaults to 15 minutes (not shown in onboarding)
5. **NEW:** User enters task name and selects frequency → taps "Dodaj"
6. **NEW:** Custom task appears in the list with same visual style as suggested
7. **NEW:** Custom task has × delete button (suggested tasks don't)
8. User can toggle custom task on/off like suggested tasks (EXISTING toggle logic)
9. **NEW:** User can tap × to delete custom task
10. User taps "Dalej" → saves rooms, suggested tasks, and custom tasks (MODIFIED save logic)

### Data Flow

```
OnbTaskSelectionPresenter (MODIFIED)
├── suggestedTasks(for:) - EXISTING
├── customTasks(for:) - NEW
├── allTasks(for:) - NEW (combines suggested + custom)
├── onTaskRowPressed(_:for:) - EXISTING (toggle selection)
├── onAddCustomTask(name:frequency:room:) - NEW
│   └── interactor.addCustomTask(...)
│       └── flowState.addCustomTask(...)
├── onDeleteCustomTask(_:room:) - NEW
│   └── interactor.removeCustomTask(...)
│       └── flowState.removeCustomTask(...)
└── onNextButtonPressed() - EXISTING
    └── router.showNextView()

OnboardingInteractor (MODIFIED)
├── suggestedTasks(for:) - EXISTING
├── toggleTask(_:for:) - EXISTING
├── addCustomTask(task, room) - NEW
├── removeCustomTask(task, room) - NEW
└── saveAndCompleteOnboarding() - MODIFIED
    ├── Save predefined rooms (EXISTING)
    ├── Save custom rooms (EXISTING)
    └── Save tasks (MODIFIED to include custom tasks):
        ├── For each room: get selectedTasks + customTasks
        └── Save both suggested and custom tasks

OnboardingFlowState (MODIFIED)
├── selectedTasks: [RoomType: [RoomTask]] - EXISTING (suggested)
├── customTasks: [RoomType: [RoomTask]] - NEW
├── addCustomTask(_:for:) - NEW
├── removeCustomTask(_:for:) - NEW
├── allTasks(for:) -> [RoomTask] - NEW
│   └── Returns selectedTasks[room] + customTasks[room]
└── toggleTask(_:for:) - EXISTING (works for both types)
```

### Visual Design

**[+ Dodaj zadanie] Button** (added after task list in each room section):
```swift
Button {
    showingAddTaskSheet = true
    selectedRoomForCustomTask = room
} label: {
    HStack(spacing: FKSpacing.small) {
        Image(systemName: "plus.circle.fill")
            .font(FKTypography.body)
        Text("onb_task_selection.action.add_custom_task")
            .font(FKTypography.body)
    }
    .foregroundStyle(Color.accentColor)
    .frame(maxWidth: .infinity)
    .padding(.vertical, FKSpacing.medium)
}
.buttonStyle(.fkFade)
```

**Modified Task Row** (add optional delete button):
```swift
private func taskRow(_ task: RoomTask, room: RoomType, isCustom: Bool = false) -> some View {
    let isSelected = presenter.isTaskSelected(task, for: room)
    return HStack(spacing: 0) {
        // EXISTING toggle button
        Button {
            FKHaptics.selection()
            presenter.onTaskRowPressed(task, for: room)
        } label: {
            HStack(spacing: FKSpacing.medium) {
                VStack(alignment: .leading, spacing: FKSpacing.extraSmall) {
                    Text(task.name)
                        .font(FKTypography.body)
                        .foregroundStyle(FKColor.Label.primary)
                    Text(task.frequency.displayName)
                        .font(FKTypography.caption)
                        .foregroundStyle(FKColor.Label.secondary)
                }
                .opacity(isSelected ? 1 : Constants.unselectedTaskRowOpacity)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(FKTypography.sectionHeader)
                    .foregroundStyle(isSelected ? Color.accentColor : Color(FKColor.Separator.default))
                    .contentTransition(.symbolEffect(.replace))
                    .accessibilityHidden(true)
            }
            .contentShape(.rect)
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .buttonStyle(.fkFade)
        
        // NEW delete button (only for custom tasks)
        if isCustom {
            Button {
                FKHaptics.selection()
                presenter.onDeleteCustomTask(task, room: room)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(FKTypography.body)
                    .foregroundStyle(FKColor.Label.secondary)
                    .padding(.leading, FKSpacing.small)
            }
            .buttonStyle(.fkFade)
        }
    }
}
```

## Scope

### In Scope
- ✅ Extend `OnboardingFlowState` with `customTasks` dictionary
- ✅ Add methods: `addCustomTask`, `removeCustomTask`, `allTasks(for:)`
- ✅ Create `OnbAddCustomTaskSheet` component
- ✅ Add [+ Dodaj zadanie] button to each room section in `OnbTaskSelectionView`
- ✅ Modify `taskRow` to show delete button for custom tasks
- ✅ Add presenter methods: `onAddCustomTask`, `onDeleteCustomTask`
- ✅ Extend `OnboardingInteractor` with custom task methods
- ✅ Modify `saveAndCompleteOnboarding()` to save custom tasks
- ✅ Add localization keys for custom task UI

### Out of Scope
- ❌ Modifying suggested tasks logic (KEEP AS-IS)
- ❌ Editing task duration during onboarding (defaults to 15 min)
- ❌ Editing custom task after creation (must delete and re-add)
- ❌ Reordering tasks
- ❌ Task icons/colors
- ❌ Bulk operations (select all, delete all custom)
- ❌ Custom task templates/suggestions

### Future Considerations
- Duration picker in add custom task sheet (quick to add if needed)
- Edit custom task functionality
- Import/export custom task templates
- AI-suggested custom tasks based on room type

## Files to Create

1. `CleaningApp/Onboarding/TaskSelection/OnbAddCustomTaskSheet.swift` - Custom task creation sheet

## Files to Modify

1. `CleaningApp/Onboarding/OnboardingFlowState.swift` - Add customTasks property and methods
2. `CleaningApp/Onboarding/TaskSelection/OnbTaskSelectionView.swift` - Add [+ Dodaj] button and delete button
3. `CleaningApp/Onboarding/TaskSelection/OnbTaskSelectionPresenter.swift` - Add custom task methods
4. `CleaningApp/Onboarding/RIB/OnboardingInteractor.swift` - Add custom task interactor methods and modify save logic
5. `CleaningApp/Resources/Localizable.xcstrings` - Add localization keys

## Success Criteria

1. ✅ [+ Dodaj zadanie] button appears at bottom of each room's task list
2. ✅ Tapping button opens sheet with task name field and frequency picker
3. ✅ Sheet "Dodaj" button disabled when task name is empty/whitespace
4. ✅ Created custom task appears in the room's task list (after suggested tasks)
5. ✅ Custom task has same visual style as suggested tasks
6. ✅ Custom task shows × delete button; suggested tasks don't
7. ✅ Tapping custom task toggles selection like suggested tasks
8. ✅ Tapping × button removes custom task with confirmation haptic
9. ✅ Custom tasks are auto-selected when created
10. ✅ Tapping "Dalej" saves rooms + selected suggested tasks + selected custom tasks
11. ✅ Custom tasks persist across app restarts after onboarding completion
12. ✅ Collapsing room section shows count including custom tasks
13. ✅ No regression in existing suggested tasks functionality
14. ✅ No crashes when adding/deleting custom tasks
15. ✅ Sheet dismisses properly on cancel or add

## Technical Notes

### Default Values
- **Custom task duration**: 15 minutes (`.fifteenMinutes`)
- **Custom task selection**: Auto-selected when created
- **Custom task frequency**: Defaults to weekly (`.timesPerWeek(1)`)

### Custom vs Suggested Task Identification
Custom tasks are identified by comparing against `room.suggestedTasks`:
```swift
func isCustomTask(_ task: RoomTask, for room: RoomType) -> Bool {
    !room.suggestedTasks.contains(task)
}
```

### State Management
- `selectedTasks` dictionary remains unchanged (only stores selected suggested tasks)
- `customTasks` dictionary stores all custom tasks per room (selection state tracked separately)
- When toggling a custom task, it's added/removed from both `customTasks` and potentially `selectedTasks`

### Error Handling
- Empty task name: "Dodaj" button disabled
- Whitespace-only task name: Trimmed and checked
- Save failure: Existing error handling in `saveAndCompleteOnboarding()` applies

### Performance
- Custom tasks list typically small (1-3 per room)
- No performance impact expected
- Entrance animations apply to custom tasks too

### Accessibility
- All interactive elements are `Button` for VoiceOver support
- Task names support Dynamic Type
- Checkmarks use SF Symbols for clarity

## Dependencies

- FulhamKit (existing) - glass styling, spacing, typography, button styles
- NavigationKit (existing) - routing (sheet is SwiftUI native)
- SwiftData (existing) - persistence
- `RoomManager` (existing)
- `RoomTaskManager` (existing)
- `OnboardingFlowState` (existing - will be extended)
- `RoomType+SuggestedTasks` (existing - NOT modified)

## Testing Strategy

### Unit Tests (Swift Testing)
- `OnboardingFlowState.addCustomTask` adds task to customTasks dictionary
- `OnboardingFlowState.removeCustomTask` removes correct task
- `OnboardingFlowState.allTasks(for:)` returns suggested + custom tasks
- Custom task toggle updates selection state correctly
- Save logic includes custom tasks in persisted data

### Integration Tests
- Add custom task → toggle → delete → add again
- Add multiple custom tasks to same room
- Add custom tasks to multiple rooms
- Save with only custom tasks selected
- Save with mix of suggested + custom tasks

### Manual Testing
- Visual verification: custom tasks look identical (except × button)
- Delete button only appears for custom tasks
- Sheet keyboard handling
- VoiceOver navigation through custom tasks
- Dynamic Type scaling in sheet

### Regression Testing
- **CRITICAL:** Verify suggested tasks still work exactly as before
- Room section collapse/expand with custom tasks
- Task selection counter includes custom tasks
- Entrance animations work with custom tasks
- Existing onboarding flow end-to-end

## Timeline Estimate

- **Small (1-2 days)**
  - Architecture is clear (extend OnboardingFlowState)
  - UI patterns already established in existing view
  - Sheet component is straightforward
  - Minimal changes to existing code (mostly additions)
  - Save logic extension is simple

## References

- `feature/onboarding-integration` branch: Complete suggested tasks implementation
- `OnbTaskSelectionView.swift`: Existing UI to extend
- `OnboardingFlowState.swift`: State management pattern to follow
- `OnboardingInteractor.swift`: Save logic to modify
- `RoomType+SuggestedTasks.swift`: Suggested tasks implementation (DO NOT TOUCH)
