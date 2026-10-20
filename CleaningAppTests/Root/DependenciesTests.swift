import Testing
@testable import CleaningApp

// MARK: - DependenciesTests

@Suite(.tags(.critical))
@MainActor
struct DependenciesTests {
    // MARK: - Tests

    @Test func init_registersSchedulingServices() {
        let dependencies = Dependencies(config: .mock)

        #expect(dependencies.dependencyContainer.resolve(SchedulingService.self) != nil)
        #expect(dependencies.dependencyContainer.resolve(CleaningScheduleCoordinator.self) != nil)
    }
}
