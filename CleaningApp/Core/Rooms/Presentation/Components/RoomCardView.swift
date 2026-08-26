import SwiftUI
import FulhamKit

struct RoomCardView: View {
	let room: Room
	
	var body: some View {
		FKCardView(showBorder: false) {
			VStack(alignment: .leading, spacing: FKSpacing.default) {
				HStack {
					Image(systemName: room.customIcon ?? room.kind.symbolName)
						.font(FKTypography.cardTitle)
						.foregroundStyle(.accent)

					Spacer()

					Menu {
						Button("Edit", systemImage: "pencil") {

						}
						Divider()
						Button("Delete", systemImage: "trash", role: .destructive) {
							
						}
					} label: {
						Image(systemName: "ellipsis")
							.foregroundStyle(.secondary)
					}
				}

				Spacer(minLength: 0)

				Text(room.name)
					.font(.headline)
					.foregroundStyle(.primary)
					.lineLimit(1)
			}
			.padding()
		}
		.fkBorder(
			cornerRadius: FKRadius.medium,
			lineWidth: FKBorder.thin,
			color: Color(FKColor.Separator.default)
		)
	}
}

#Preview {
	RoomCardView(room: .mock)
}
