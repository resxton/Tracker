extension TrackerCD {
    func toDomain() -> Tracker? {
        guard let id = id,
              let name = name,
              let color = color,
              let emoji = emoji else {
            return nil
        }

        let schedule = Schedule(rawValue: Int(schedule))

        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
}
