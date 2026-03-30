import Foundation
import Testing
@testable import CleaningApp

// MARK: - CompletedTaskMapperTests

@Suite(.tags(.persistence))
@MainActor
struct CompletedTaskMapperTests {
	private let mapper = CompletedTaskMapper()

	// MARK: - toDomain

	@Test func toDomain_mapsAllFields() {
		let entity = CompletedTaskEntity.mock
		let domain = mapper.toDomain(entity)

		#expect(domain.id == entity.id)
		#expect(domain.taskId == entity.taskId)
		#expect(domain.completedAt == entity.completedAt)
		#expect(domain.measuredDuration == entity.measuredDuration)
	}

	@Test func toDomain_mapsNilMeasuredDuration() {
		let entity = CompletedTaskEntity(
			id: UUID(),
			taskId: UUID(),
			completedAt: .mock,
			measuredDuration: nil
		)
		let domain = mapper.toDomain(entity)
		#expect(domain.measuredDuration == nil)
	}

	@Test func toDomain_mapsNonNilMeasuredDuration() {
		let entity = CompletedTaskEntity(
			id: UUID(),
			taskId: UUID(),
			completedAt: .mock,
			measuredDuration: 42
		)
		let domain = mapper.toDomain(entity)
		#expect(domain.measuredDuration == 42)
	}

	// MARK: - toEntity

	@Test func toEntity_mapsAllFields() throws {
		let domain = try #require(CompletedTask.mocks.first)
		let entity = mapper.toEntity(domain)

		#expect(entity.id == domain.id)
		#expect(entity.taskId == domain.taskId)
		#expect(entity.completedAt == domain.completedAt)
		#expect(entity.measuredDuration == domain.measuredDuration)
	}

	@Test func toEntity_preservesNilMeasuredDuration() {
		let domain = CompletedTask(
			id: UUID(),
			taskId: UUID(),
			completedAt: .mock,
			measuredDuration: nil
		)
		let entity = mapper.toEntity(domain)
		#expect(entity.measuredDuration == nil)
	}

	// MARK: - Round-trip

	@Test func toDomain_thenToEntity_preservesAllFields() throws {
		let domain = try #require(CompletedTask.mocks.first)
		let entity = mapper.toEntity(domain)
		let restored = mapper.toDomain(entity)

		#expect(restored.id == domain.id)
		#expect(restored.taskId == domain.taskId)
		#expect(restored.completedAt == domain.completedAt)
		#expect(restored.measuredDuration == domain.measuredDuration)
	}

	@Test func toEntity_thenToDomain_preservesAllFields() {
		let entity = CompletedTaskEntity.mock
		let domain = mapper.toDomain(entity)
		let restored = mapper.toEntity(domain)

		#expect(restored.id == entity.id)
		#expect(restored.taskId == entity.taskId)
		#expect(restored.completedAt == entity.completedAt)
		#expect(restored.measuredDuration == entity.measuredDuration)
	}
}
