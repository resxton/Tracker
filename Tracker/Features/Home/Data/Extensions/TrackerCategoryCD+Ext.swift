extension TrackerCategoryCD {
    func toDomain() -> TrackerCategory? {
        guard let title = title,
              let trackersCD = trackers as? Set<TrackerCD> else {
            return nil
        }

        let trackers = trackersCD.compactMap { $0.toDomain() }
        return TrackerCategory(title: title, trackers: trackers)
    }
}
