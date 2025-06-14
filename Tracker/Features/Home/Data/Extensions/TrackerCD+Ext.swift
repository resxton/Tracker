extension TrackerCD {
    func toDomain() -> Tracker? {
        guard let id = id,
              let name = name,
              let color = color,
              let emoji = emoji else { return nil }
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: Schedule(rawValue: Int(schedule)),
            categoryTitle: category?.title
        )
    }
}
