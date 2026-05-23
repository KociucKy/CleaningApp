import Foundation
import Testing
@testable import CleaningApp

// MARK: - NotificationSchedulerTests

@Suite(.tags(.onboarding))
@MainActor
struct NotificationSchedulerTests {
	// MARK: - scheduleDailyReminder

	@Test func scheduleDailyReminder_recordsScheduledTime() throws {
		let scheduler = MockNotificationScheduler()

		// Create a specific time (9:30 AM)
		var components = DateComponents()
		components.hour = 9
		components.minute = 30
		let time = try #require(Calendar.current.date(from: components))

		// Schedule the reminder
		try scheduler.scheduleDailyReminder(at: time)

		// Verify the time was recorded
		#expect(scheduler.scheduledTime == time)
		#expect(scheduler.scheduleCallCount == 1)
	}

	@Test func scheduleDailyReminder_incrementsCallCount() throws {
		let scheduler = MockNotificationScheduler()

		var components = DateComponents()
		components.hour = 9
		components.minute = 0
		let time = try #require(Calendar.current.date(from: components))

		// Schedule multiple times
		try scheduler.scheduleDailyReminder(at: time)
		try scheduler.scheduleDailyReminder(at: time)
		try scheduler.scheduleDailyReminder(at: time)

		// Verify call count
		#expect(scheduler.scheduleCallCount == 3)
	}

	@Test func scheduleDailyReminder_throwsErrorWhenConfigured() throws {
		let scheduler = MockNotificationScheduler()
		scheduler.shouldThrowError = true

		var components = DateComponents()
		components.hour = 9
		components.minute = 0
		let time = try #require(Calendar.current.date(from: components))

		// Verify error is thrown
		#expect(throws: Error.self) {
			try scheduler.scheduleDailyReminder(at: time)
		}

		// Verify state was not updated
		#expect(scheduler.scheduledTime == nil)
		#expect(scheduler.scheduleCallCount == 0)
	}

	@Test func scheduleDailyReminder_overwritesPreviousTime() throws {
		let scheduler = MockNotificationScheduler()

		// Schedule first time (9:00 AM)
		var components1 = DateComponents()
		components1.hour = 9
		components1.minute = 0
		let time1 = try #require(Calendar.current.date(from: components1))
		try scheduler.scheduleDailyReminder(at: time1)

		// Schedule second time (14:30 PM)
		var components2 = DateComponents()
		components2.hour = 14
		components2.minute = 30
		let time2 = try #require(Calendar.current.date(from: components2))
		try scheduler.scheduleDailyReminder(at: time2)

		// Verify only the latest time is recorded
		#expect(scheduler.scheduledTime == time2)
		#expect(scheduler.scheduleCallCount == 2)
	}

	// MARK: - cancelDailyReminder

	@Test func cancelDailyReminder_clearsScheduledTime() throws {
		let scheduler = MockNotificationScheduler()

		// Schedule a reminder first
		var components = DateComponents()
		components.hour = 9
		components.minute = 0
		let time = try #require(Calendar.current.date(from: components))
		try scheduler.scheduleDailyReminder(at: time)

		// Verify it was scheduled
		#expect(scheduler.scheduledTime == time)

		// Cancel the reminder
		scheduler.cancelDailyReminder()

		// Verify it was cleared
		#expect(scheduler.scheduledTime == nil)
		#expect(scheduler.cancelCallCount == 1)
	}

	@Test func cancelDailyReminder_incrementsCallCount() {
		let scheduler = MockNotificationScheduler()

		// Cancel multiple times
		scheduler.cancelDailyReminder()
		scheduler.cancelDailyReminder()
		scheduler.cancelDailyReminder()

		// Verify call count
		#expect(scheduler.cancelCallCount == 3)
	}

	@Test func cancelDailyReminder_worksEvenIfNothingWasScheduled() {
		let scheduler = MockNotificationScheduler()

		// Cancel without scheduling first
		scheduler.cancelDailyReminder()

		// Verify no error and state is nil
		#expect(scheduler.scheduledTime == nil)
		#expect(scheduler.cancelCallCount == 1)
	}
}
