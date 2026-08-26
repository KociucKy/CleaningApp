import SwiftUI
import FulhamKit

struct RoomsGridView<Content: View>: View {
	// MARK: - Properties

	private let columns = [
		GridItem(.flexible(), spacing: FKSpacing.medium),
		GridItem(.flexible(), spacing: FKSpacing.medium)
	]
	var rooms: [Room]
	@ViewBuilder var cardView: (Room) -> Content

	// MARK: - Body
	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns, spacing: FKSpacing.medium) {
				ForEach(rooms) { room in
					cardView(room)
				}
			}
			.padding(.horizontal, FKSpacing.large)
		}
	}
}

#Preview {
	RoomsGridView(rooms: Room.mocks) { room in
		RoomCardView(room: room)
	}
}
