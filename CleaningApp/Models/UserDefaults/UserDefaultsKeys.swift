import Foundation
import UserDefaultsKit

extension UserDefaultsKey where Value == Bool {
	static let showOnboarding = UserDefaultsKey("showOnboarding", defaultValue: true)
}
