#if MOCK
	import Foundation

	extension Date {
		// 2025-01-01 12:00:00 UTC — stable anchor for all mock dates
		static let mock = Date(timeIntervalSince1970: 1_735_732_800)
	}
#endif
