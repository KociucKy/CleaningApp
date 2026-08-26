import Foundation
import FulhamKit
import SwiftUI

// MARK: - OnbProgressView

@MainActor
struct OnbProgressView: View {
    // MARK: - Properties

    let stage: OnbProgressStage

    // MARK: - Computed Properties

    private var accessibilityValue: String {
        String.localizedStringWithFormat(
            String(localized: "onb_progress.accessibility.value"),
            Int64(stage.stepNumber),
            Int64(stage.totalSteps),
            String(localized: stage.accessibilityName)
        )
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: FKSpacing.extraSmall) {
            ForEach(OnbProgressStage.allCases, id: \.self) { progressStage in
                Capsule()
                    .fill(progressStage.rawValue <= stage.rawValue ? Color.accentColor : Color.accentColor.opacity(0.18))
                    .frame(maxWidth: .infinity)
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, FKSpacing.large)
        .padding(.top, FKSpacing.small)
        .padding(.bottom, FKSpacing.extraSmall)
        .animation(.easeInOut(duration: 0.25), value: stage)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("onb_progress.accessibility.label")
        .accessibilityValue(Text(verbatim: accessibilityValue))
    }
}
