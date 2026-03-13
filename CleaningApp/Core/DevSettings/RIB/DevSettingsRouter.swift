import Foundation
import NavigationKit

// MARK: - DevSettingsRouter

@MainActor
protocol DevSettingsRouter {
    func dismissDevSettings()
}

extension CoreRouter: DevSettingsRouter {}