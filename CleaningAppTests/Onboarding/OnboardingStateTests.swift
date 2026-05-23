import Foundation
import Testing
import UserDefaultsKit
@testable import CleaningApp

// MARK: - OnboardingStateTests

@Suite(.tags(.onboarding, .critical))
@MainActor
struct OnboardingStateTests {
	// MARK: - updateViewState

	@Test func updateViewState_trueFalse_incrementsCompletionToken() {
		let original = UserDefaultsStore.standard.get(.showOnboarding)
		defer { UserDefaultsStore.standard.set(original, for: .showOnboarding) }
		let state = OnboardingState(showOnboarding: true)
		state.updateViewState(showOnboarding: false)
		#expect(state.completionToken == 1)
	}

	@Test func updateViewState_falseFalse_doesNotIncrementCompletionToken() {
		let original = UserDefaultsStore.standard.get(.showOnboarding)
		defer { UserDefaultsStore.standard.set(original, for: .showOnboarding) }
		let state = OnboardingState(showOnboarding: false)
		state.updateViewState(showOnboarding: false)
		#expect(state.completionToken == 0)
	}

	@Test func updateViewState_falseTrue_doesNotIncrementCompletionToken() {
		let original = UserDefaultsStore.standard.get(.showOnboarding)
		defer { UserDefaultsStore.standard.set(original, for: .showOnboarding) }
		let state = OnboardingState(showOnboarding: false)
		state.updateViewState(showOnboarding: true)
		#expect(state.completionToken == 0)
	}

	@Test func updateViewState_trueTrue_doesNotIncrementCompletionToken() {
		let original = UserDefaultsStore.standard.get(.showOnboarding)
		defer { UserDefaultsStore.standard.set(original, for: .showOnboarding) }
		let state = OnboardingState(showOnboarding: true)
		state.updateViewState(showOnboarding: true)
		#expect(state.completionToken == 0)
	}

	@Test func updateViewState_repeatedFalseCalls_incrementsOnlyOnce() {
		let original = UserDefaultsStore.standard.get(.showOnboarding)
		defer { UserDefaultsStore.standard.set(original, for: .showOnboarding) }
		let state = OnboardingState(showOnboarding: true)
		state.updateViewState(showOnboarding: false)
		state.updateViewState(showOnboarding: false)
		state.updateViewState(showOnboarding: false)
		#expect(state.completionToken == 1)
	}

	@Test func updateViewState_multipleTrueFalseTransitions_incrementsEachTime() {
		let original = UserDefaultsStore.standard.get(.showOnboarding)
		defer { UserDefaultsStore.standard.set(original, for: .showOnboarding) }
		let state = OnboardingState(showOnboarding: false)
		state.updateViewState(showOnboarding: true)
		state.updateViewState(showOnboarding: false)
		state.updateViewState(showOnboarding: true)
		state.updateViewState(showOnboarding: false)
		#expect(state.completionToken == 2)
	}

	// MARK: - showOnboarding

	@Test func updateViewState_updatesShowOnboarding() {
		let original = UserDefaultsStore.standard.get(.showOnboarding)
		defer { UserDefaultsStore.standard.set(original, for: .showOnboarding) }
		let state = OnboardingState(showOnboarding: true)
		state.updateViewState(showOnboarding: false)
		#expect(state.showOnboarding == false)
	}
}
