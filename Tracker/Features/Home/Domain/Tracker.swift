import Foundation

struct Tracker: Codable {
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let schedule: Schedule
    let categoryTitle: String?
    let isPinned: Bool
}

struct Schedule: OptionSet, Codable {
    let rawValue: Int

    static let monday = Schedule(rawValue: 1 << 0)
    static let tuesday = Schedule(rawValue: 1 << 1)
    static let wednesday = Schedule(rawValue: 1 << 2)
    static let thursday = Schedule(rawValue: 1 << 3)
    static let friday = Schedule(rawValue: 1 << 4)
    static let saturday = Schedule(rawValue: 1 << 5)
    static let sunday = Schedule(rawValue: 1 << 6)

    static let everyDay: Schedule = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
}
