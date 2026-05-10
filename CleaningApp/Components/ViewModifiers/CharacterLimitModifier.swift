import SwiftUI

// MARK: - CharacterLimitModifier

struct CharacterLimitModifier: ViewModifier {
	// MARK: - Properties

	@Binding var text: String
	let maxLength: Int

	// MARK: - Body

	func body(content: Content) -> some View {
		content
			.onChange(of: text) {
				limitTextLength()
			}
	}

	// MARK: - Methods

	private func limitTextLength() {
		if text.count > maxLength {
			text = String(text.prefix(maxLength))
		}
	}
}

// MARK: - CharacterCountFooter

struct CharacterCountFooter: View {
	// MARK: - Properties

	let currentCount: Int
	let maxLength: Int
	let limitReachedKey: String

	// MARK: - Body

	var body: some View {
		HStack {
			if currentCount == maxLength {
				Text(LocalizedStringKey(limitReachedKey))
					.font(.caption)
					.foregroundStyle(characterCountColor)
					.transition(.opacity.combined(with: .scale))
			}
			Spacer()
			Text("\(currentCount)/\(maxLength)")
				.font(.caption)
				.foregroundStyle(characterCountColor)
				.contentTransition(.numericText())
		}
		.animation(.smooth, value: currentCount)
	}

	// MARK: - Computed Properties

	private var characterCountColor: Color {
		let warningThreshold = maxLength - 5
		let dangerThreshold = maxLength - 2

		switch currentCount {
		case dangerThreshold...:
			return .red
		case warningThreshold ..< dangerThreshold:
			return .orange
		default:
			return .secondary
		}
	}
}

// MARK: - View Extension

extension View {
	func withCharacterLimit(
		_ text: Binding<String>,
		maxLength: Int = 30
	) -> some View {
		modifier(CharacterLimitModifier(
			text: text,
			maxLength: maxLength
		))
	}

	func characterCountFooter(
		currentCount: Int,
		maxLength: Int = 30,
		limitReachedKey: String = "onb_custom_room.character_limit_reached"
	) -> some View {
		CharacterCountFooter(
			currentCount: currentCount,
			maxLength: maxLength,
			limitReachedKey: limitReachedKey
		)
	}
}
