import Foundation
import NavigationKit

// MARK: - SettingsRouter

@MainActor
protocol SettingsRouter {
    func dismissScreen()
}

extension CoreRouter: SettingsRouter {}