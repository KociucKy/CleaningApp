# CleaningApp Specification Overview

**Last Updated**: 2026-04-25  
**Architecture**: RIB (Router-Interactor-Builder) + Presenter + View  
**Platform**: iOS 18.0+, Swift 6.0, SwiftUI

---

## What is CleaningApp?

CleaningApp is an iOS home cleaning task management system. Users create rooms, assign recurring cleaning tasks, and track completion over time.

**Core Concept**: Structure home cleaning by room, track what needs to be done and when, and build consistent cleaning habits.

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       CLEANINGAPP                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ONBOARDING (First-time setup)                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │ Welcome  │─▶│  Rooms   │─▶│  Tasks   │─▶│Completed │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  MAIN APP (Tab navigation)                                     │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │    HOME     │  │    ROOMS    │  │  SETTINGS   │            │
│  │             │  │             │  │             │            │
│  │ View all    │  │ Manage      │  │ App config  │            │
│  │ rooms/tasks │  │ rooms/tasks │  │             │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Domain Model

### Core Entities

```
Room ────── has many ──────▶ RoomTask
  │                              │
  │ • id: UUID                   │ • id: UUID
  │ • name: String               │ • name: String
  │ • kind: RoomType             │ • roomId: UUID
  │ • createdAt: Date            │ • frequency: Frequency
  │                              │ • estimatedDuration: TaskDuration
  │                              │ • createdAt: Date
  │                              │
  │                              ├─── tracked by ────▶ CompletedTask
  │                              │                      • taskId: UUID
  │                              │                      • completedAt: Date
  │                              │                      • measuredDuration: Int?
  │                              │
  │                              └─── can be ────────▶ SkippedTask
  │                                                     • taskId: UUID
  │                                                     • originalDate: Date
  │                                                     • skippedAt: Date
```

**Key Relationships**:
- **Rooms contain Tasks**: 1-to-many relationship
- **Tasks tracked by Completions**: Historical record of doing the task
- **Tasks tracked by Skips**: Historical record of not doing the task
- **Cascade deletion**: Deleting room deletes all its tasks
- **Orphaned history**: Deleting task leaves completion/skip records intact

---

## Specification Structure

### Domain Specs (`openspec/specs/domain/`)

Document the **data models** and business rules:

- **`room.md`**: Room entity, room types, suggested tasks
- **`task.md`**: RoomTask entity, creation/deletion rules
- **`frequency.md`**: Frequency enum (15+ recurrence patterns)
- **`tracking.md`**: CompletedTask and SkippedTask models

### Capability Specs (`openspec/specs/capabilities/`)

Document what **users can do**:

- **`onboarding.md`**: First-time setup flow (rooms → tasks → complete)
- **`room-management.md`**: Create, view, edit, delete rooms
- **`task-management.md`**: Create, view, edit, delete tasks
- **`task-tracking.md`**: Mark complete/skipped, view history

---

## Key Features

### ✅ Implemented

1. **Onboarding Flow**
   - Welcome screen
   - Room selection (10 predefined types)
   - Task selection (suggested tasks per room type)
   - Notifications prompt
   - Paywall
   - Data persistence

2. **Data Layer**
   - SwiftData persistence
   - Domain models (Room, RoomTask, CompletedTask, SkippedTask)
   - Repository pattern
   - Manager layer
   - Mock repositories for testing

3. **Business Logic**
   - RIB architecture (Router-Interactor-Builder)
   - Presenter layer (connects View ↔ Interactor/Router)
   - Dependency injection
   - @Observable state management

4. **Suggested Tasks**
   - 40-50 pre-configured tasks across 9 room types
   - Localized names
   - Sensible frequency/duration defaults
   - Stable UUIDs for identity

### ⚠️ Partially Implemented

5. **Room Management**
   - ✅ Backend: fetch, save, delete
   - ❓ Frontend: List view, add/edit UI unknown

6. **Task Management**
   - ✅ Backend: fetch, save, delete
   - ❓ Frontend: List view, add/edit UI unknown

7. **Task Tracking**
   - ✅ Backend: save completion/skip, fetch history
   - ❓ Frontend: Complete button, history view unknown

### ❌ Not Implemented

8. **Scheduling System**
   - No "next due date" calculation
   - No overdue status
   - No reminders/notifications

9. **Analytics**
   - No completion rate
   - No streak tracking
   - No duration learning
   - No progress dashboards

10. **Advanced Features**
    - No calendar view
    - No photos
    - No bulk operations
    - No task templates library
    - No sharing/collaboration

---

## Data Highlights

### Room Types (9 predefined + custom)
- Kitchen, Living Room, Bedroom, Bathroom, Hallway
- Office, Garage, Laundry, Toilet
- Custom (no suggested tasks)

### Frequency Options (15+ patterns)
- **Daily**: daily, every other day, every X days
- **Weekly**: X times per week, every X weeks
- **Monthly**: X times per month, every X months
- **Long-term**: quarterly, biannually, yearly

### Task Duration (5 fixed buckets)
- 5, 10, 15, 30, 60 minutes

### Suggested Tasks
- ~40-50 tasks total across all room types
- 4-7 tasks per room type
- Examples: "Wipe countertops", "Vacuum floor", "Clean toilet"

---

## Architecture Patterns

### RIB Pattern
```
Feature/
├── Presentation/
│   ├── FeatureView.swift         # SwiftUI View - no logic
│   └── FeaturePresenter.swift    # @Observable bridge to Interactor/Router
└── RIB/
    ├── FeatureBuilder.swift      # Wires dependencies
    ├── FeatureInteractor.swift   # Protocol + CoreInteractor extension
    └── FeatureRouter.swift       # Protocol + CoreRouter extension
```

**Key characteristics**:
- **Single CoreInteractor**: Conforms to all feature interactor protocols
- **Single CoreRouter**: Conforms to all feature router protocols
- **Presenters hold protocols**: `private let interactor: any FeatureInteractor`
- **Business logic in Services**: Not in Interactors/Presenters

### Data Layer
```
Domain (pure Swift structs)
   ↕ Mapper
Entities (SwiftData @Model classes)
   ↕ Repository (protocol + implementations)
Manager (wraps repository, used by Interactors)
```

**Dual implementations**:
- **MockRepository**: In-memory, for testing (scheme: CleaningApp - Mock)
- **SwiftDataRepository**: Persistent, for dev/prod

---

## Open Questions & Future Directions

### Critical Missing Pieces
1. **Scheduling**: How to calculate "next due date"? Store or compute?
2. **Reminders**: How should notifications work?
3. **UI Completion**: Rooms and Tasks tabs need UI implementation

### Design Decisions to Make
1. **Validation**: Should invalid data throw errors or fail silently?
2. **Data Retention**: Should deleted tasks also delete history? Or keep orphaned records?
3. **Frequency Flexibility**: Support calendar-based patterns (e.g., "every Monday")?

### Feature Opportunities
1. **Analytics Dashboard**: Completion rates, streaks, time spent
2. **Calendar Integration**: Visualize tasks on calendar
3. **Collaboration**: Share task lists with family/roommates
4. **Gamification**: Achievements, leaderboards, motivational features
5. **Smart Scheduling**: Learn from completion patterns, adjust estimates

---

## How to Use This Specification

### For New Features
1. Read relevant capability spec to understand current state
2. Read domain specs to understand data models
3. Propose changes in OpenSpec format
4. Implement following RIB architecture pattern

### For Bug Fixes
1. Check domain specs for business rules
2. Verify expected behavior in capability specs
3. Identify where actual behavior diverges

### For Onboarding New Contributors
1. Start with this overview
2. Read `domain/room.md` and `domain/task.md` (core models)
3. Read `capabilities/onboarding.md` (user journey)
4. Explore codebase with specs as map

---

## Specification Maintenance

### When to Update
- New features added → Create/update capability spec
- Data model changes → Update domain spec
- Business rules change → Update both domain and capability specs
- Open questions answered → Remove from "Open Questions", update spec

### Spec Ownership
- **Domain specs**: Focus on data structures, validation, persistence
- **Capability specs**: Focus on user actions, workflows, UI patterns
- **This overview**: High-level system map, links between specs

---

## Quick Reference

| I want to... | Read this spec |
|--------------|----------------|
| Understand the data model | `domain/room.md`, `domain/task.md` |
| See what users can do | All files in `capabilities/` |
| Learn about frequency patterns | `domain/frequency.md` |
| Understand onboarding flow | `capabilities/onboarding.md` |
| Know how tracking works | `domain/tracking.md`, `capabilities/task-tracking.md` |
| Get the big picture | This file |

---

## Implementation Status Legend

- ✅ **Implemented**: Feature exists and works
- ⚠️ **Partially Implemented**: Backend done, UI unknown or incomplete
- ❌ **Not Implemented**: Planned but not yet built
- ❓ **Unknown**: Status unclear from code inspection

---

**Last Reviewed**: 2026-04-25  
**Reviewed By**: System analysis of codebase  
**Next Review**: When major features are added or architecture changes
