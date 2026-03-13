import Foundation
import NavigationKit

// MARK: - HomeRouter

@MainActor
protocol HomeRouter {
    func dismissScreen()
    func presentDevSettings()
}

extension CoreRouter: HomeRouter {}