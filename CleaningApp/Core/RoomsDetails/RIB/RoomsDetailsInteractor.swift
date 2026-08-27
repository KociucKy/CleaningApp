import Foundation

@MainActor
protocol RoomsDetailsInteractor {
    func fetchAllRoomTasks(for roomId: UUID) throws -> [RoomTask]
    func fetchAllCompletedTasks(for taskId: UUID) throws -> [CompletedTask]
    func saveCompletedTask(_ task: CompletedTask) throws
    func deleteCompletedTask(_ task: CompletedTask) throws
}

extension CoreInteractor: RoomsDetailsInteractor {}
