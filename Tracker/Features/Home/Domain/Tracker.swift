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

struct Schedule: OptionSet, Codable, Hashable {
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

extension Schedule {
    static func fromWeekday(_ weekday: Int) -> Schedule {
        switch weekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return []
        }
    }
    
    var name: String {
        if self == .monday { return "Понедельник" }
        if self == .tuesday { return "Вторник" }
        if self == .wednesday { return "Среда" }
        if self == .thursday { return "Четверг" }
        if self == .friday { return "Пятница" }
        if self == .saturday { return "Суббота" }
        if self == .sunday { return "Воскресенье" }
        return ""
    }
    
    var selectedDays: [Schedule] {
        var days: [Schedule] = []
        if self.contains(.monday) { days.append(.monday) }
        if self.contains(.tuesday) { days.append(.tuesday) }
        if self.contains(.wednesday) { days.append(.wednesday) }
        if self.contains(.thursday) { days.append(.thursday) }
        if self.contains(.friday) { days.append(.friday) }
        if self.contains(.saturday) { days.append(.saturday) }
        if self.contains(.sunday) { days.append(.sunday) }
        return days
    }
    
    var count: Int {
        return selectedDays.count
    }
}
