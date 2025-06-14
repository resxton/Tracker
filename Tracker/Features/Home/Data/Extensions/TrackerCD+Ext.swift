extension TrackerCD {
    func toDomain() -> Tracker? {
        guard let id = id,
              let name = name,
              let color = color,
              let emoji = emoji else { return nil }
        // Возвращаем Tracker без рекурсивной категории
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: Schedule(rawValue: Int(schedule)),
            categoryTitle: category?.title // Передаем только title категории, избегая цикла
        )
    }
}
