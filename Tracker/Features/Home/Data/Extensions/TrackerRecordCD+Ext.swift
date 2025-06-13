extension TrackerRecordCD {
    func toDomain() -> TrackerRecord? {
        guard let id = id, let date = date else { return nil }
        return TrackerRecord(id: id, date: date)
    }
}
