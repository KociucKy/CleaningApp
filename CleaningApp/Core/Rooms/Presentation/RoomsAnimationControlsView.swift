import SwiftUI

// MARK: - RoomsAnimationControlsView

struct RoomsAnimationControlsView: View {
    // MARK: - Properties

    @Binding private var configuration: RoomsAnimationConfiguration
    private let replay: () -> Void

    // MARK: - Init

    init(configuration: Binding<RoomsAnimationConfiguration>, replay: @escaping () -> Void) {
        _configuration = configuration
        self.replay = replay
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Rooms animation", systemImage: "wand.and.stars")
                    .font(.headline)

                Spacer()

                Button("Replay", systemImage: "arrow.clockwise", action: replay)
                    .labelStyle(.iconOnly)
                    .accessibilityLabel("Replay rooms animation")
            }

            slider(title: "Duration", value: $configuration.duration, range: 0.08...0.6, step: 0.01, suffix: "s")
            slider(title: "Stagger", value: $configuration.stagger, range: 0...0.16, step: 0.005, suffix: "s")
            slider(title: "Offset", value: $configuration.offset, range: 0...40, step: 1, suffix: "pt")
            slider(title: "Scale", value: $configuration.scale, range: 0.9...1, step: 0.005, suffix: "")
        }
        .padding(14)
        .frame(maxWidth: 320)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.16), radius: 16, y: 8)
        .padding()
    }

    // MARK: - Views

    private func slider(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        suffix: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(title)
                Spacer()
                Text("\(value.wrappedValue, specifier: "%.3g")\(suffix)")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            Slider(value: value, in: range, step: step)
        }
        .font(.caption)
    }
}
