import Foundation
import Testing
@testable import CleaningApp

// MARK: - RoomMapperTests

@Suite(.tags(.persistence))
@MainActor
struct RoomMapperTests {
	private let mapper = RoomMapper()

	// MARK: - toDomain

	@Test func toDomain_mapsAllFields() {
		let entity = RoomEntity.mock
		let domain = mapper.toDomain(entity)

		#expect(domain.id == entity.id)
		#expect(domain.name == entity.name)
		#expect(domain.createdAt == entity.createdAt)
	}

	@Test func toDomain_mapsKnownIcon() {
		let entity = RoomEntity(
			id: UUID(),
			name: "Kitchen",
			icon: "Kitchen",
			createdAt: .mock
		)
		let domain = mapper.toDomain(entity)
		#expect(domain.icon == .kitchen)
	}

	@Test func toDomain_unknownIconFallsBackToCustom() {
		let entity = RoomEntity(
			id: UUID(),
			name: "Mystery Room",
			icon: "nonExistentIcon",
			createdAt: .mock
		)
		let domain = mapper.toDomain(entity)
		#expect(domain.icon == .custom)
	}

	@Test func toDomain_allKnownIcons() {
		for icon in RoomIcon.allCases {
			let entity = RoomEntity(id: UUID(), name: "Room", icon: icon.rawValue, createdAt: .mock)
			let domain = mapper.toDomain(entity)
			#expect(domain.icon == icon)
		}
	}

	// MARK: - toEntity

	@Test func toEntity_mapsAllFields() {
		let domain = Room.mock
		let entity = mapper.toEntity(domain)

		#expect(entity.id == domain.id)
		#expect(entity.name == domain.name)
		#expect(entity.createdAt == domain.createdAt)
	}

	@Test func toEntity_storesIconAsRawValue() {
		let domain = Room(
			id: UUID(),
			name: "Bathroom",
			icon: .bathroom,
			createdAt: .mock
		)
		let entity = mapper.toEntity(domain)
		#expect(entity.icon == RoomIcon.bathroom.rawValue)
	}

	// MARK: - Round-trip

	@Test func toDomain_thenToEntity_preservesAllFields() {
		let original = Room.mock
		let entity = mapper.toEntity(original)
		let restored = mapper.toDomain(entity)

		#expect(restored.id == original.id)
		#expect(restored.name == original.name)
		#expect(restored.icon == original.icon)
		#expect(restored.createdAt == original.createdAt)
	}

	@Test func toEntity_thenToDomain_preservesAllFields() {
		let original = RoomEntity.mock
		let domain = mapper.toDomain(original)
		let restored = mapper.toEntity(domain)

		#expect(restored.id == original.id)
		#expect(restored.name == original.name)
		#expect(restored.icon == original.icon)
		#expect(restored.createdAt == original.createdAt)
	}
}
