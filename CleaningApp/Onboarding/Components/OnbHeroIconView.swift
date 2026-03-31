import SwiftUI

struct OnbHeroIconView: View {
	private enum Constants {
		static let lightIconCircleOpacity: CGFloat = 0.12
		static let darkIconCircleOpacity: CGFloat = 0.2
		static let iconCircleSize: CGFloat = 120.0
		static let iconSymbolSize: CGFloat = 52
		static let iconEntryScale: CGFloat = 0.6
	}

	@Environment(\.colorScheme) private var colorScheme
	var systemName: String
	var iconVisible: Bool

	var body: some View {
		ZStack {
			Circle()
				.fill(
					Color.accentColor.opacity(colorScheme == .light ? Constants.lightIconCircleOpacity : Constants.darkIconCircleOpacity)
				)
				.frame(width: Constants.iconCircleSize, height: Constants.iconCircleSize)
			Image(systemName: systemName)
				.font(.system(size: Constants.iconSymbolSize, weight: .light))
				.foregroundStyle(Color.accentColor)
				.symbolEffect(.bounce, options: .nonRepeating, isActive: iconVisible)
		}
		.scaleEffect(iconVisible ? 1 : Constants.iconEntryScale)
		.opacity(iconVisible ? 1 : 0)
	}
}

#Preview {
	OnbHeroIconView(systemName: "bubbles.and.sparkles.fill", iconVisible: true)
}
