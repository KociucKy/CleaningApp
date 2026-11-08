import Foundation
import Testing
@testable import CleaningApp

// MARK: - SchedulingInvariantValidatorTests

@Suite(.tags(.home, .critical))
@MainActor
struct SchedulingInvariantValidatorTests {
    // MARK: - Properties

    private let service = SchedulingService()

    // MARK: - Tests

    @Test(
        arguments: [
            SchedulingScenario.balancedWeek,
            SchedulingScenario.existingAndOverdueWork,
            SchedulingScenario.capacityPressure,
            SchedulingScenario.longTask
        ]
    )
    func makeMutation_satisfiesPlanningInvariants(
        scenario: SchedulingScenario
    ) throws {
        let mutation = service.makeMutation(input: scenario.input)

        #expect(
            SchedulingInvariantValidator.violations(
                for: mutation,
                input: scenario.input,
                service: service
            ).isEmpty
        )
    }

    // MARK: - Private

    @MainActor
    struct SchedulingScenario {
        // MARK: - Properties

        let name: String
        let input: SchedulingInput
        private static let calendar: Calendar = {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
            return calendar
        }()

        // MARK: - Fixtures

        static var balancedWeek: Self {
            let today = makeDate(day: 19)
            return Self(
                name: "Balanced week",
                input: SchedulingInput(
                    tasks: [
                        makeTask(name: "Counters", frequency: .daily, duration: .fifteenMinutes),
                        makeTask(name: "Bathroom", frequency: .timesPerWeek(2), duration: .twentyMinutes),
                        makeTask(name: "Vacuum", frequency: .weekly, duration: .thirtyMinutes),
                        makeTask(name: "Windows", frequency: .everyOtherWeek, duration: .fortyFiveMinutes)
                    ],
                    scheduledTasks: [],
                    completedTasks: [],
                    skippedTasks: [],
                    today: today,
                    dailyLimit: 60,
                    calendar: calendar
                )
            )
        }

        static var existingAndOverdueWork: Self {
            let today = makeDate(day: 19)
            let backlogTask = makeTask(
                name: "Backlog",
                frequency: .weekly,
                duration: .twentyMinutes
            )
            let overdueTask = makeTask(
                name: "Overdue",
                frequency: .weekly,
                duration: .twentyMinutes
            )
            let plannedTask = makeTask(
                name: "Preserved",
                frequency: .weekly,
                duration: .fifteenMinutes
            )

            return Self(
                name: "Existing, overdue, and backlog work",
                input: SchedulingInput(
                    tasks: [backlogTask, overdueTask, plannedTask],
                    scheduledTasks: [
                        ScheduledTask(
                            taskId: backlogTask.id,
                            scheduledDate: makeDate(day: 17),
                            originalScheduledDate: makeDate(day: 17),
                            status: .postponed,
                            createdAt: today,
                            updatedAt: today
                        ),
                        ScheduledTask(
                            taskId: overdueTask.id,
                            scheduledDate: makeDate(day: 18),
                            originalScheduledDate: makeDate(day: 18),
                            createdAt: today,
                            updatedAt: today
                        ),
                        ScheduledTask(
                            taskId: plannedTask.id,
                            scheduledDate: makeDate(day: 21),
                            createdAt: today,
                            updatedAt: today
                        )
                    ],
                    completedTasks: [],
                    skippedTasks: [],
                    today: today,
                    dailyLimit: 45,
                    calendar: calendar
                )
            )
        }

        static var capacityPressure: Self {
            let today = makeDate(day: 19)
            let reservedTask = makeTask(
                name: "Reserved",
                frequency: .weekly,
                duration: .thirtyMinutes
            )

            return Self(
                name: "Capacity pressure",
                input: SchedulingInput(
                    tasks: [
                        reservedTask,
                        makeTask(name: "Daily one", frequency: .daily, duration: .fifteenMinutes),
                        makeTask(name: "Daily two", frequency: .daily, duration: .fifteenMinutes),
                        makeTask(name: "Weekly", frequency: .timesPerWeek(3), duration: .fifteenMinutes)
                    ],
                    scheduledTasks: [
                        ScheduledTask(
                            taskId: reservedTask.id,
                            scheduledDate: makeDate(day: 20),
                            createdAt: today,
                            updatedAt: today
                        )
                    ],
                    completedTasks: [],
                    skippedTasks: [],
                    today: today,
                    dailyLimit: 30,
                    calendar: calendar
                )
            )
        }

        static var longTask: Self {
            let today = makeDate(day: 19)
            return Self(
                name: "Long task",
                input: SchedulingInput(
                    tasks: [
                        makeTask(name: "Deep clean", frequency: .weekly, duration: .sixtyMinutes),
                        makeTask(name: "Counters", frequency: .daily, duration: .fifteenMinutes)
                    ],
                    scheduledTasks: [],
                    completedTasks: [],
                    skippedTasks: [],
                    today: today,
                    dailyLimit: 30,
                    calendar: calendar
                )
            )
        }

        // MARK: - Helpers

        private static func makeTask(
            name: String,
            frequency: Frequency,
            duration: TaskDuration
        ) -> RoomTask {
            RoomTask(
                name: name,
                roomId: UUID(),
                frequency: frequency,
                estimatedDuration: duration,
                createdAt: makeDate(day: 1)
            )
        }

        private static func makeDate(day: Int) -> Date {
            calendar.date(
                from: DateComponents(
                    calendar: calendar,
                    timeZone: calendar.timeZone,
                    year: 2026,
                    month: 10,
                    day: day
                )
            ) ?? .distantPast
        }
    }
}

// MARK: - SchedulingInvariantValidator

@MainActor
private enum SchedulingInvariantValidator {
    // MARK: - Methods

    static func violations(
        for mutation: ScheduleMutation,
        input: SchedulingInput,
        service: SchedulingService
    ) -> [String] {
        let horizon = service.makeHorizon(today: input.today, calendar: input.calendar)
        let updatedOccurrencesByID = Dictionary(
            uniqueKeysWithValues: mutation.occurrencesToUpdate.map { ($0.id, $0) }
        )
        let resultingOccurrences = input.scheduledTasks.map {
            updatedOccurrencesByID[$0.id] ?? $0
        } + mutation.occurrencesToCreate
        let plannedOccurrences = resultingOccurrences.filter { $0.status == .planned }
        let tasksByID = Dictionary(uniqueKeysWithValues: input.tasks.map { ($0.id, $0) })

        var violations: [String] = []

        for occurrence in mutation.occurrencesToCreate where occurrence.status == .planned {
            if !horizon.days.contains(occurrence.scheduledDate) {
                violations.append("Created planned work outside the horizon.")
            }
        }

        let occurrencesByDay = Dictionary(grouping: plannedOccurrences) {
            input.calendar.startOfDay(for: $0.scheduledDate)
        }
        for (day, occurrences) in occurrencesByDay {
            let taskIDs = occurrences.map(\.taskId)
            if Set(taskIDs).count != taskIDs.count {
                violations.append("A task was planned more than once on \(day).")
            }

            let durations = occurrences.compactMap {
                tasksByID[$0.taskId].map { $0.learnedDuration ?? $0.estimatedDuration.rawValue }
            }
            let totalDuration = durations.reduce(0, +)
            let hasExclusiveTask = durations.contains { $0 > input.dailyLimit }

            if hasExclusiveTask {
                if occurrences.count != 1 {
                    violations.append("A long task was not kept exclusive on \(day).")
                }
            } else if totalDuration > input.dailyLimit + 2 {
                violations.append("The daily limit was exceeded on \(day).")
            }
        }

        let originalPlannedOccurrences = input.scheduledTasks.filter {
            $0.status == .planned && horizon.days.contains($0.scheduledDate)
        }
        for occurrence in originalPlannedOccurrences {
            if updatedOccurrencesByID[occurrence.id] != nil {
                violations.append("A preserved planned occurrence was changed.")
            }
        }

        let inputOccurrenceIDs = Set(input.scheduledTasks.map(\.id))
        for occurrence in mutation.occurrencesToCreate {
            if let sourceOccurrenceID = occurrence.sourceOccurrenceId,
               !inputOccurrenceIDs.contains(sourceOccurrenceID) {
                violations.append("A successor references an unknown occurrence.")
            }
        }

        let refreshedInput = SchedulingInput(
            tasks: input.tasks,
            scheduledTasks: resultingOccurrences,
            completedTasks: input.completedTasks,
            skippedTasks: input.skippedTasks,
            today: input.today,
            dailyLimit: input.dailyLimit,
            calendar: input.calendar
        )
        let followUpMutation = service.makeMutation(input: refreshedInput)
        if !followUpMutation.occurrencesToCreate.isEmpty || !followUpMutation.occurrencesToUpdate.isEmpty {
            violations.append("Refreshing an unchanged plan was not idempotent.")
        }

        return violations
    }
}
