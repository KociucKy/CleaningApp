import Foundation
import Testing
@testable import CleaningApp

// MARK: - RoomTypeSuggestedTasksTests

@Suite(.tags(.onboarding))
struct RoomTypeSuggestedTasksTests {
	// MARK: - Stability

	@Test(.tags(.critical)) func suggestedTasks_returnsSameIdsAcrossMultipleCalls() {
		for roomType in RoomType.allCases {
			let firstCall = roomType.suggestedTasks.map(\.id)
			let secondCall = roomType.suggestedTasks.map(\.id)
			#expect(firstCall == secondCall, "UUIDs must be stable for \(roomType)")
		}
	}

	@Test(.tags(.critical)) func suggestedTasks_idsAreUniqueWithinRoom() {
		for roomType in RoomType.allCases {
			let ids = roomType.suggestedTasks.map(\.id)
			#expect(ids.count == Set(ids).count, "Duplicate UUIDs found for \(roomType)")
		}
	}

	@Test(.tags(.critical)) func suggestedTasks_idsAreUniqueAcrossAllRooms() {
		let allIds = RoomType.allCases.flatMap { $0.suggestedTasks.map(\.id) }
		#expect(allIds.count == Set(allIds).count)
	}

	// MARK: - Content

	@Test func suggestedTasks_everyRoomHasAtLeastOneTask() {
		for roomType in RoomType.allCases where roomType != .custom {
			#expect(!roomType.suggestedTasks.isEmpty, "\(roomType) has no suggested tasks")
		}
	}

	@Test func suggestedTasks_everyTaskHasNonEmptyName() {
		for roomType in RoomType.allCases where roomType != .custom {
			for task in roomType.suggestedTasks {
				#expect(!task.name.isEmpty, "Empty task name found in \(roomType)")
			}
		}
	}
}
