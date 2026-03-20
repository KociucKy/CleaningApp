import Foundation
import Testing
@testable import CleaningApp

// MARK: - RoomTaskMapperTests

@Suite(.tags(.persistence))
@MainActor
struct RoomTaskMapperTests {
	private let mapper = RoomTaskMapper()

	// MARK: - toDomain

	@Test func toDomain_mapsAllFields() {
		let entity = RoomTaskEntity.mock
		let domain = mapper.toDomain(entity)

		#expect(domain.id == entity.id)
		#expect(domain.name == entity.name)
		#expect(domain.roomId == entity.room?.id)
		#expect(domain.createdAt == entity.createdAt)
	}

	@Test func toDomain_decodesFrequency() {
		let entity = RoomTaskEntity(
			id: UUID(),
			name: "Task",
			room: .mock,
			frequencyEncoded: "timesPerWeek(2)",
			estimatedDuration: 30,
			createdAt: .mock
		)
		let domain = mapper.toDomain(entity)
		#expect(domain.frequency == .timesPerWeek(2))
	}

	@Test func toDomain_mapsKnownDuration() {
		for duration in TaskDuration.allCases {
			let entity = RoomTaskEntity(
				id: UUID(),
				name: "Task",
				room: .mock,
				frequencyEncoded: "daily",
				estimatedDuration: duration.rawValue,
				createdAt: .mock
			)
			let domain = mapper.toDomain(entity)
			#expect(domain.estimatedDuration == duration)
		}
	}

	@Test func toDomain_unknownDurationFallsBackToFifteenMinutes() {
		let entity = RoomTaskEntity(
			id: UUID(),
			name: "Task",
			room: .mock,
			frequencyEncoded: "daily",
			estimatedDuration: 999,
			createdAt: .mock
		)
		let domain = mapper.toDomain(entity)
		#expect(domain.estimatedDuration == .fifteenMinutes)
	}

	@Test func toDomain_nilRoomGeneratesNewRoomId() {
		let entity = RoomTaskEntity(
			id: UUID(),
			name: "Orphan Task",
			room: nil,
			frequencyEncoded: "daily",
			estimatedDuration: 15,
			createdAt: .mock
		)
		// Should not crash; roomId is filled with a new UUID
		let domain = mapper.toDomain(entity)
		#expect(domain.name == "Orphan Task")
	}

	// MARK: - toEntity

	@Test func toEntity_mapsAllFields() {
		let domain = RoomTask.mock
		let roomEntity = RoomEntity.mock
		let entity = mapper.toEntity(domain, roomEntity: roomEntity)

		#expect(entity.id == domain.id)
		#expect(entity.name == domain.name)
		#expect(entity.room?.id == roomEntity.id)
		#expect(entity.createdAt == domain.createdAt)
	}

	@Test func toEntity_encodesFrequency() {
		let domain = RoomTask(
			id: UUID(),
			name: "Task",
			roomId: Room.mockId,
			frequency: .monthly,
			estimatedDuration: .thirtyMinutes,
			createdAt: .mock
		)
		let entity = mapper.toEntity(domain, roomEntity: .mock)
		#expect(entity.frequencyEncoded == "monthly")
	}

	@Test func toEntity_storesDurationAsRawValue() {
		let domain = RoomTask(
			id: UUID(),
			name: "Task",
			roomId: Room.mockId,
			frequency: .daily,
			estimatedDuration: .sixtyMinutes,
			createdAt: .mock
		)
		let entity = mapper.toEntity(domain, roomEntity: .mock)
		#expect(entity.estimatedDuration == TaskDuration.sixtyMinutes.rawValue)
	}

	// MARK: - Round-trip

	@Test func toDomain_thenToEntity_preservesAllFields() {
		let original = RoomTask.mock
		let roomEntity = RoomEntity.mock
		let entity = mapper.toEntity(original, roomEntity: roomEntity)
		let restored = mapper.toDomain(entity)

		#expect(restored.id == original.id)
		#expect(restored.name == original.name)
		#expect(restored.roomId == original.roomId)
		#expect(restored.frequency == original.frequency)
		#expect(restored.estimatedDuration == original.estimatedDuration)
		#expect(restored.createdAt == original.createdAt)
	}
}
