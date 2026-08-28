import Foundation

@MainActor
protocol RoomsDetailsTaskCompletionInteractor {
	func saveCompletedTask(_ item: CompletedTask) throws
}

extension CoreInteractor: RoomsDetailsTaskCompletionInteractor {}

