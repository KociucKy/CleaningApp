import Foundation
import Testing
@testable import CleaningApp

// MARK: - MockRoomRepositoryTests

@Suite(.tags(.persistence))
@MainActor
struct MockRoomRepositoryTests {
	// MARK: - fetchAll

	@Test func fetchAll_returnsSeededItems() throws {
		let repo = MockRoomRepository()
		let result = try repo.fetchAll()
		#expect(result.count == RoomEntity.mocks.count)
	}

	@Test func fetchAll_returnsEmptyAfterRemovingAll() throws {
		let repo = MockRoomRepository()
		repo.items = []
		let result = try repo.fetchAll()
		#expect(result.isEmpty)
	}

	// MARK: - fetch(by:)

	@Test func fetchById_returnsMatchingEntity() throws {
		let repo = MockRoomRepository()
		let result = try repo.fetch(by: RoomEntity.mockId)
		#expect(result?.id == RoomEntity.mockId)
	}

	@Test func fetchById_returnsNilForUnknownId() throws {
		let repo = MockRoomRepository()
		let result = try repo.fetch(by: UUID())
		#expect(result == nil)
	}

	// MARK: - save

	@Test(.tags(.adding)) func save_insertsNewEntity() throws {
		let repo = MockRoomRepository()
		let newEntity = RoomEntity(id: UUID(), name: "New Room", icon: "custom", createdAt: .mock)
		try repo.save(newEntity)
		let all = try repo.fetchAll()
		#expect(all.contains { $0.id == newEntity.id })
	}

	@Test(.tags(.adding)) func save_upsertsExistingEntity() throws {
		let repo = MockRoomRepository()
		let existing = RoomEntity.mock
		existing.name = "Updated Name"
		try repo.save(existing)
		let fetched = try repo.fetch(by: existing.id)
		#expect(fetched?.name == "Updated Name")
	}

	@Test(.tags(.adding)) func save_doesNotDuplicateExistingEntity() throws {
		let repo = MockRoomRepository()
		let countBefore = repo.items.count
		let existing = RoomEntity.mock
		try repo.save(existing)
		#expect(repo.items.count == countBefore)
	}

	// MARK: - delete

	@Test(.tags(.deleting)) func delete_removesMatchingEntity() throws {
		let repo = MockRoomRepository()
		let target = RoomEntity.mock
		try repo.delete(target)
		let result = try repo.fetch(by: target.id)
		#expect(result == nil)
	}

	@Test(.tags(.deleting)) func delete_doesNotAffectOtherEntities() throws {
		let repo = MockRoomRepository()
		let countBefore = repo.items.count
		let target = RoomEntity.mock
		try repo.delete(target)
		#expect(repo.items.count == countBefore - 1)
	}

	@Test(.tags(.deleting)) func delete_noOpForNonExistentEntity() throws {
		let repo = MockRoomRepository()
		let countBefore = repo.items.count
		let ghost = RoomEntity(id: UUID(), name: "Ghost", icon: "custom", createdAt: .mock)
		try repo.delete(ghost)
		#expect(repo.items.count == countBefore)
	}
}
