extension TrackerCategoryCD {
    func toDomain() -> TrackerCategory? {
        guard let title = title else { return nil }
        let trackers = (trackers?.allObjects as? [TrackerCD])?.compactMap { $0.toDomain() } ?? []
        return TrackerCategory(title: title, trackers: trackers)
    }
}
