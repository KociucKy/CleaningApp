import SwiftUI

// MARK: - RoomsAnimationConfiguration

struct RoomsAnimationConfiguration: Equatable {
    // MARK: - Properties

    var duration = 0.33
    var stagger = 0.04
    var offset = 17.0
    var scale = 0.94
    var runID = 0

    // MARK: - Animation

    var animation: Animation {
        .easeOut(duration: duration)
    }

    func delay(for index: Int) -> Double {
        Double(index) * stagger
    }
}
