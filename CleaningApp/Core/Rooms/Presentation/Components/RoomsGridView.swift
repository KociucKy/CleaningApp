import FulhamKit
import SwiftUI

// MARK: - RoomsGridView

struct RoomsGridView<Content: View>: View {
	// MARK: - Properties

	@State private var isVisible = false
	private let columns = [
		GridItem(.flexible(), spacing: FKSpacing.medium),
		GridItem(.flexible(), spacing: FKSpacing.medium)
	]
	let rooms: [Room]
	let animationConfiguration: RoomsAnimationConfiguration
	let isActive: Bool
	@ViewBuilder let cardView: (Room) -> Content

	// MARK: - Body

	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns, spacing: FKSpacing.medium) {
				ForEach(Array(rooms.enumerated()), id: \.element.id) { index, room in
					cardView(room)
						.opacity(isVisible ? 1 : 0)
						.offset(y: isVisible ? 0 : animationConfiguration.offset)
						.scaleEffect(isVisible ? 1 : animationConfiguration.scale)
						.animation(
							animationConfiguration.animation.delay(animationConfiguration.delay(for: index)),
							value: isVisible
						)
				}
			}
			.padding(.horizontal, FKSpacing.large)
		}
		.onAppear {
			if isActive {
				restartAnimation()
			}
		}
		.onChange(of: isActive) { _, active in
			if active {
				restartAnimation()
			} else {
				hideCards()
			}
		}
		.onChange(of: animationConfiguration.runID) {
			restartAnimation()
		}
	}

	// MARK: - Animation

	private func restartAnimation() {
		hideCards()

		DispatchQueue.main.async {
			guard isActive else {
				return
			}
			withAnimation(.easeOut(duration: animationConfiguration.duration)) {
				isVisible = true
			}
		}
	}

	private func hideCards() {
		var transaction = Transaction()
		transaction.animation = nil
		withTransaction(transaction) {
			isVisible = false
		}
	}
}

// MARK: - Preview

#Preview {
	RoomsGridView(rooms: Room.mocks, animationConfiguration: RoomsAnimationConfiguration(), isActive: true) { room in
		RoomCardView(room: room)
	}
}
