import Foundation
import NavigationKit

// MARK: - SettingsInteractor

@MainActor
protocol SettingsInteractor {
	func dailyScheduleLimit() -> Int
	func updateDailyScheduleLimit(_ dailyLimit: Int) throws
}

extension CoreInteractor: SettingsInteractor {}
