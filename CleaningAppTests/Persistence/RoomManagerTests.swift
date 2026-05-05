import Foundation
import Testing
@testable import CleaningApp

// MARK: - RoomManagerTests

@Suite(.tags(.persistence))
@MainActor
struct RoomManagerTests {
	// MARK: - fetchAll

	@Test func fetchAll_returnsMappedDomainModels() throws {
		let manager = RoomManager(repository: MockRoomRepository())
		let rooms = try manager.fetchAll()
		#expect(rooms.count == RoomEntity.mocks.count)
	}

	@Test func fetchAll_returnsEmptyWhenRepositoryIsEmpty() throws {
		let repo = MockRoomRepository()
		repo.items = []
		let manager = RoomManager(repository: repo)
		let rooms = try manager.fetchAll()
		#expect(rooms.isEmpty)
	}

	@Test func fetchAll_mapsIdCorrectly() throws {
		let manager = RoomManager(repository: MockRoomRepository())
		let rooms = try manager.fetchAll()
		let ids = rooms.map(\.id)
		let entityIds = RoomEntity.mocks.map(\.id)
		#expect(Set(ids) == Set(entityIds))
	}

	// MARK: - save

	@Test(.tags(.adding)) func save_persistsNewRoom() throws {
		let repo = MockRoomRepository()
		let manager = RoomManager(repository: repo)
		let newRoom = Room(id: UUID(), name: "Garage", kind: .garage, createdAt: .mock)
		try manager.save(newRoom)
		let all = try manager.fetchAll()
		#expect(all.contains { $0.id == newRoom.id })
	}

	@Test(.tags(.adding)) func save_updatesExistingRoom() throws {
		let repo = MockRoomRepository()
		let manager = RoomManager(repository: repo)
		var room = Room.mock
		room.name = "Updated Living Room"
		try manager.save(room)
		let all = try manager.fetchAll()
		let found = all.first { $0.id == room.id }
		#expect(found?.name == "Updated Living Room")
	}

	// MARK: - delete

	@Test(.tags(.deleting)) func delete_removesRoom() throws {
		let repo = MockRoomRepository()
		let manager = RoomManager(repository: repo)
		let room = Room.mock
		try manager.delete(room)
		let all = try manager.fetchAll()
		#expect(!all.contains { $0.id == room.id })
	}

	@Test(.tags(.deleting)) func delete_doesNotAffectOtherRooms() throws {
		let repo = MockRoomRepository()
		let manager = RoomManager(repository: repo)
		let countBefore = try manager.fetchAll().count
		let room = Room.mock
		try manager.delete(room)
		let countAfter = try manager.fetchAll().count
		#expect(countAfter == countBefore - 1)
	}
}
