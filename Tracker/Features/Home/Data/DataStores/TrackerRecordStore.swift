import CoreData

final class TrackerRecordStore {
    private let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    private var viewContext: NSManagedObjectContext {
        coreDataStack.viewContext
    }

    // MARK: - Create

    func create(record: TrackerRecord, trackerID: UUID) throws {
        let request: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)

        guard let trackerCD = try viewContext.fetch(request).first else {
            throw NSError(domain: "TrackerRecordStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Tracker not found"])
        }

        let recordCD = TrackerRecordCD(context: viewContext)
        recordCD.id = record.id
        recordCD.date = record.date
        recordCD.tracker = trackerCD

        try save()
    }

    // MARK: - Fetch

    func fetchAll() throws -> [TrackerRecord] {
        let request: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        let recordsCD = try viewContext.fetch(request)
        return recordsCD.compactMap { $0.toDomain() }
    }

    func fetch(for trackerID: UUID, on date: Date) throws -> TrackerRecord? {
        let request: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "tracker.id == %@", trackerID as CVarArg),
            NSPredicate(format: "date == %@", date as NSDate)
        ])
        return try viewContext.fetch(request).first?.toDomain()
    }

    // MARK: - Delete

    func delete(recordID: UUID) throws {
        let request: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", recordID as CVarArg)

        if let recordCD = try viewContext.fetch(request).first {
            viewContext.delete(recordCD)
            try save()
        }
    }

    func deleteAll(for trackerID: UUID) throws {
        let request: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        request.predicate = NSPredicate(format: "tracker.id == %@", trackerID as CVarArg)

        let records = try viewContext.fetch(request)
        for record in records {
            viewContext.delete(record)
        }

        try save()
    }

    // MARK: - Save

    private func save() throws {
        if viewContext.hasChanges {
            try viewContext.save()
        }
    }
}

extension TrackerRecordCD {
    func toDomain() -> TrackerRecord? {
        guard let id = id, let date = date else { return nil }
        return TrackerRecord(id: id, date: date)
    }
}
