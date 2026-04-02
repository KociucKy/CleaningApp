import SwiftUI
import UserDefaultsKit

// MARK: - OnboardingState

@Observable
final class OnboardingState {
	// MARK: - Properties

	private(set) var showOnboarding: Bool {
		didSet {
			UserDefaultsStore.standard.set(showOnboarding, for: .showOnboarding)
		}
	}

	private(set) var completionToken = 0

	// MARK: - Init

	init(showOnboarding: Bool = UserDefaultsStore.standard.get(.showOnboarding)) {
		self.showOnboarding = showOnboarding
	}

	// MARK: - Update

	func updateViewState(showOnboarding: Bool) {
		self.showOnboarding = showOnboarding
		if !showOnboarding {
			completionToken += 1
		}
	}
}
