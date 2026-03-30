import Foundation
import Testing
@testable import CleaningApp

// MARK: - SkippedTaskMapperTests

@Suite(.tags(.persistence))
@MainActor
struct SkippedTaskMapperTests {
	private let mapper = SkippedTaskMapper()

	// MARK: - toDomain

	@Test func toDomain_mapsAllFields() {
		let entity = SkippedTaskEntity.mock
		let domain = mapper.toDomain(entity)

		#expect(domain.id == entity.id)
		#expect(domain.taskId == entity.taskId)
		#expect(domain.originalDate == entity.originalDate)
		#expect(domain.skippedAt == entity.skippedAt)
	}

	// MARK: - toEntity

	@Test func toEntity_mapsAllFields() throws {
		let domain = try #require(SkippedTask.mocks.first)
		let entity = mapper.toEntity(domain)

		#expect(entity.id == domain.id)
		#expect(entity.taskId == domain.taskId)
		#expect(entity.originalDate == domain.originalDate)
		#expect(entity.skippedAt == domain.skippedAt)
	}

	// MARK: - Round-trip

	@Test func toDomain_thenToEntity_preservesAllFields() throws {
		let domain = try #require(SkippedTask.mocks.first)
		let entity = mapper.toEntity(domain)
		let restored = mapper.toDomain(entity)

		#expect(restored.id == domain.id)
		#expect(restored.taskId == domain.taskId)
		#expect(restored.originalDate == domain.originalDate)
		#expect(restored.skippedAt == domain.skippedAt)
	}

	@Test func toEntity_thenToDomain_preservesAllFields() {
		let entity = SkippedTaskEntity.mock
		let domain = mapper.toDomain(entity)
		let restored = mapper.toEntity(domain)

		#expect(restored.id == entity.id)
		#expect(restored.taskId == entity.taskId)
		#expect(restored.originalDate == entity.originalDate)
		#expect(restored.skippedAt == entity.skippedAt)
	}
}
