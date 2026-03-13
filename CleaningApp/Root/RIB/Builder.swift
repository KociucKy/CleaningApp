import SwiftUI

// MARK: - Builder

@MainActor
protocol Builder {
    func build() -> AnyView
}