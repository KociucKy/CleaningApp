import SwiftUI
import FulhamKit

struct RoomsDetailsHeaderView: View {
	private enum Constants {
		static let symbolSize: CGFloat = 55.0
		static let lightModeOpacity: CGFloat = 0.12
		static let darkModeOpacity: CGFloat = 0.32
	}

	@Environment(\.colorScheme) private var colorScheme
	let symbol: String
	let roomName: String

	private var tintOpacity: CGFloat {
		colorScheme == .light ? Constants.lightModeOpacity : Constants.darkModeOpacity
	}

	var body: some View {
		VStack(spacing: FKSpacing.medium) {
			Image(systemName: symbol)
				.font(.title)
				.frame(
					width: Constants.symbolSize,
					height: Constants.symbolSize
				)
				.padding(FKSpacing.default)
				.background(.tint.opacity(tintOpacity), in: .circle)
			Text(roomName)
				.font(FKTypography.statValue)
		}
		.removeListRowFormatting()
	}
}

#Preview {
	RoomsDetailsHeaderView(symbol: "sofa", roomName: "Living Room")
}
