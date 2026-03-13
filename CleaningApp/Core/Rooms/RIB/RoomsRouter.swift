import Foundation
import NavigationKit

// MARK: - RoomsRouter

@MainActor
protocol RoomsRouter {
    func dismissScreen()
}

extension CoreRouter: RoomsRouter {}