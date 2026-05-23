import Foundation
import UserDefaultsKit

extension UserDefaultsKey where Value == Bool {
	static let showOnboarding = UserDefaultsKey("showOnboarding", defaultValue: true)
}

extension UserDefaultsKey where Value == Date {
	static let notificationTime = UserDefaultsKey("notificationTime", defaultValue: {
		var components = DateComponents()
		components.hour = 9
		components.minute = 0
		return Calendar.current.date(from: components) ?? Date()
	}())
}
