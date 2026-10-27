import Foundation

// MARK: - ScheduleWeekday

@MainActor
enum ScheduleWeekday: Int, CaseIterable, Identifiable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    // MARK: - Properties

    nonisolated var id: Self { self }

    var name: String {
        localizedName(in: .current)
    }

    var shortName: String {
        localizedShortName(in: .current)
    }

    var date: String {
        "\(14 + rawValue)"
    }

    // MARK: - Init

    init(date: Date, calendar: Calendar) {
        switch calendar.component(.weekday, from: date) {
        case 2: self = .monday
        case 3: self = .tuesday
        case 4: self = .wednesday
        case 5: self = .thursday
        case 6: self = .friday
        case 7: self = .saturday
        default: self = .sunday
        }
    }

    // MARK: - Methods

    func localizedName(in calendar: Calendar) -> String {
        calendar.weekdaySymbols[calendarWeekday - 1]
            .capitalized(with: calendar.locale ?? .current)
    }

    func localizedShortName(in calendar: Calendar) -> String {
        calendar.shortWeekdaySymbols[calendarWeekday - 1]
            .capitalized(with: calendar.locale ?? .current)
    }

    // MARK: - Private

    private var calendarWeekday: Int {
        switch self {
        case .monday: 2
        case .tuesday: 3
        case .wednesday: 4
        case .thursday: 5
        case .friday: 6
        case .saturday: 7
        case .sunday: 1
        }
    }
}
