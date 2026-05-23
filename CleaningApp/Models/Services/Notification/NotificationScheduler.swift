import Foundation
import LocalNotificationKit
import UserNotifications

// MARK: - NotificationScheduling

@MainActor
protocol NotificationScheduling {
	func scheduleDailyReminder(at time: Date) throws
	func cancelDailyReminder()
}

// MARK: - NotificationScheduler

@MainActor
final class NotificationScheduler: NotificationScheduling {
	// MARK: - Properties

	private let notificationManager: any LocalNotificationManaging
	private static let dailyReminderIdentifier = "daily-cleaning-reminder"

	// MARK: - Init

	init(notificationManager: any LocalNotificationManaging = LocalNotificationManager.shared) {
		self.notificationManager = notificationManager
	}

	// MARK: - Methods

	func scheduleDailyReminder(at time: Date) throws {
		// Extract hour and minute from the selected time
		let components = Calendar.current.dateComponents([.hour, .minute], from: time)

		// Cancel any existing daily reminder before scheduling a new one
		cancelDailyReminder()

		// Create the notification content using UNNotificationContent directly
		let content = UNMutableNotificationContent()
		content.title = String(localized: "notification.daily_reminder.title")
		content.body = String(localized: "notification.daily_reminder.body")
		content.sound = .default

		// Create a calendar trigger for daily repeating
		let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

		// Create the request
		let request = UNNotificationRequest(
			identifier: Self.dailyReminderIdentifier,
			content: content,
			trigger: trigger
		)

		// Schedule the notification
		UNUserNotificationCenter.current().add(request) { error in
			if let error {
				print("Failed to schedule notification: \(error)")
			}
		}
	}

	func cancelDailyReminder() {
		UNUserNotificationCenter.current().removePendingNotificationRequests(
			withIdentifiers: [Self.dailyReminderIdentifier]
		)
	}
}

// MARK: - MockNotificationScheduler

#if MOCK
	@MainActor
	final class MockNotificationScheduler: NotificationScheduling {
		// MARK: - Properties

		private(set) var scheduledTime: Date?
		private(set) var scheduleCallCount = 0
		private(set) var cancelCallCount = 0
		var shouldThrowError = false

		// MARK: - Methods

		func scheduleDailyReminder(at time: Date) throws {
			if shouldThrowError {
				throw NSError(domain: "MockNotificationScheduler", code: 1, userInfo: nil)
			}
			scheduledTime = time
			scheduleCallCount += 1
		}

		func cancelDailyReminder() {
			scheduledTime = nil
			cancelCallCount += 1
		}
	}
#endif
