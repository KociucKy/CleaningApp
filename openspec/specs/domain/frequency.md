# Domain: Frequency

**Status**: Implemented  
**Last Updated**: 2026-04-25

---

## Overview

**Frequency** defines how often a cleaning task should be performed. It's a highly flexible enum supporting daily, weekly, monthly, and custom recurrence patterns.

This is one of the most sophisticated domain models in CleaningApp, supporting 15+ different frequency patterns.

---

## Domain Model

```swift
enum Frequency: Equatable, Codable {
    // Daily
    case daily
    case everyOtherDay
    case everyXDays(Int)
    
    // Weekly
    case timesPerWeek(Int)
    case everyOtherWeek
    case everyXWeeks(Int)
    
    // Monthly
    case timesPerMonth(Int)
    case monthly
    case everyXMonths(Int)
    
    // Long-term
    case quarterly          // Every 3 months
    case biannually         // Every 6 months
    case yearly
}
```

---

## Frequency Patterns

### Daily Patterns
| Pattern | Example Use Case | Display Name |
|---------|------------------|--------------|
| `.daily` | Make bed, wipe kitchen counters | "Daily" |
| `.everyOtherDay` | Water plants, check mail | "Every other day" |
| `.everyXDays(4)` | Clean bathroom mirror | "Every 4 days" |

### Weekly Patterns
| Pattern | Example Use Case | Display Name |
|---------|------------------|--------------|
| `.timesPerWeek(1)` | Vacuum bedroom, mop floors | "Once a week" |
| `.timesPerWeek(2)` | Clean kitchen sink, empty bins | "2 times per week" |
| `.timesPerWeek(3)` | Wipe bathroom sink | "3 times per week" |
| `.everyOtherWeek` | Change bed sheets, clean windows | "Every other week" |
| `.everyXWeeks(3)` | Deep clean fridge | "Every 3 weeks" |

### Monthly Patterns
| Pattern | Example Use Case | Display Name |
|---------|------------------|--------------|
| `.monthly` | Clean oven, tidy wardrobe | "Monthly" |
| `.timesPerMonth(2)` | Defrost freezer | "2 times per month" |
| `.everyXMonths(2)` | Wash curtains | "Every 2 months" |

### Long-term Patterns
| Pattern | Example Use Case | Display Name |
|---------|------------------|--------------|
| `.quarterly` | Service HVAC, deep clean garage | "Quarterly" (every 3 months) |
| `.biannually` | Flip mattress, clean gutters | "Biannually" (every 6 months) |
| `.yearly` | Service appliances, paint walls | "Yearly" |

---

## Localization

All frequency patterns have **localized display names**:

```swift
var displayName: String {
    switch self {
    case .daily:
        String(localized: "frequency.daily")
    case .everyOtherDay:
        String(localized: "frequency.every_other_day")
    case let .everyXDays(days):
        String.localizedStringWithFormat(
            String(localized: "frequency.every_x_days"), 
            Int64(days)
        )
    // ... etc
    }
}
```

**Special handling for singular vs. plural**:
- `.timesPerWeek(1)` → "Once a week" (special case)
- `.timesPerWeek(2)` → "2 times per week" (formatted)
- `.timesPerMonth(1)` → "Monthly" (special case, not "1 time per month")

---

## Persistence

### Encoding

Frequency is **serialized to/from string** for SwiftData storage via `FrequencyEncoder`:

```swift
@MainActor
enum FrequencyEncoder {
    static func encode(_ frequency: Frequency) -> String
    static func decode(_ encoded: String) -> Frequency
}
```

**Example encodings**:
- `.daily` → `"daily"`
- `.timesPerWeek(3)` → `"timesPerWeek:3"`
- `.everyXMonths(2)` → `"everyXMonths:2"`

**Storage**: In `RoomTaskEntity`, stored as `frequencyEncoded: String`

---

## Business Rules

### Valid Values
- **Daily**: `everyXDays(n)` where `n >= 1` (n=1 should use `.daily` instead)
- **Weekly**: `timesPerWeek(n)` where `n >= 1`, `everyXWeeks(n)` where `n >= 1`
- **Monthly**: `timesPerMonth(n)` where `n >= 1`, `everyXMonths(n)` where `n >= 1`
- **Long-term**: Fixed values (quarterly = 3mo, biannually = 6mo, yearly = 12mo)

### Validation
- No explicit validation in current implementation
- Invalid values (e.g., `timesPerWeek(0)`) are possible but nonsensical
- UI should constrain to valid ranges

### Recurrence Calculation
**Not yet implemented**. Current system defines frequency but doesn't:
- Calculate next due date
- Track overdue tasks
- Send reminders
- Generate recurring instances

---

## Design Considerations

### Why Associated Values?

The enum uses associated values for flexible patterns:
- `.timesPerWeek(Int)` allows 1, 2, 3, etc. without defining separate cases
- `.everyXDays(Int)` supports arbitrary day intervals
- More extensible than fixed enum cases

**Trade-off**: More complex encoding/decoding logic

### Why Not Calendar-Based?

Current model is **interval-based** (every N days/weeks/months), not **calendar-based** (every Monday, first of month).

**Limitations**:
- Can't express "every Monday and Thursday"
- Can't express "first Tuesday of every month"
- Can't handle irregular patterns (e.g., "weekdays only")

**Benefit**: Simpler model, easier internationalization

---

## Usage Patterns

### Most Common Frequencies in Suggested Tasks
Based on `RoomType+SuggestedTasks.swift`:

| Frequency | Count | Percentage |
|-----------|-------|------------|
| `.timesPerWeek(1-3)` | ~25 | 50% |
| `.daily` | ~8 | 16% |
| `.monthly` | ~8 | 16% |
| `.quarterly` | ~4 | 8% |
| `.everyOtherDay` | ~2 | 4% |
| Other | ~3 | 6% |

**Insight**: Most tasks are weekly (1-3x), with daily and monthly as secondary patterns.

---

## Open Questions

1. **Recurrence Engine**: How should next-due-date be calculated? Should it be stored or computed?
2. **Calendar Integration**: Should we support calendar-based patterns (e.g., "every Monday")?
3. **Validation**: Should invalid frequencies be rejected at construction time?
4. **Flexible Scheduling**: Should users be able to "reschedule" a specific instance without changing the overall frequency?
5. **Frequency Changes**: When frequency is changed, what happens to past completion history?
6. **Time-of-Day**: Should frequency include time-of-day preferences (e.g., "daily at 8am")?

---

## Implementation References

- Domain: `Models/Domain/Frequency.swift`
- Encoding: `Models/Services/Frequency/FrequencyEncoder.swift`
- Usage: `Models/Domain/RoomTask.swift` (property `frequency: Frequency`)
- Suggested defaults: `Models/Domain/RoomType+SuggestedTasks.swift`
