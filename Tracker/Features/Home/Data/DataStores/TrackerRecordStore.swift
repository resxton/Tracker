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

    /// Создаёт новую запись выполнения трекера на дату, если её ещё нет
    func addRecord(for trackerID: UUID, on date: Date) throws {
        guard try !isRecordExist(for: trackerID, on: date) else { return }
        
        let trackerRequest: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        trackerRequest.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)

        guard let trackerCD = try viewContext.fetch(trackerRequest).first else {
            throw NSError(domain: "TrackerRecordStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Tracker not found"])
        }

        let recordCD = TrackerRecordCD(context: viewContext)
        recordCD.id = UUID()
        recordCD.date = date
        recordCD.tracker = trackerCD

        try save()
    }

    // MARK: - Check existence

    /// Проверяет, есть ли запись выполнения трекера на дату
    func isRecordExist(for trackerID: UUID, on date: Date) throws -> Bool {
        let request: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "tracker.id == %@", trackerID as CVarArg),
            NSPredicate(format: "date == %@", date as NSDate)
        ])
        let count = try viewContext.count(for: request)
        return count > 0
    }

    // MARK: - Count

    /// Считает количество выполненных дней для трекера
    func countRecords(for trackerID: UUID) throws -> Int {
        let request: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        request.predicate = NSPredicate(format: "tracker.id == %@", trackerID as CVarArg)
        let count = try viewContext.count(for: request)
        return count
    }

    // MARK: - Delete

    /// Удаляет запись выполнения трекера на конкретную дату, если она существует
    func removeRecord(for trackerID: UUID, on date: Date) throws {
        let request: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "tracker.id == %@", trackerID as CVarArg),
            NSPredicate(format: "date == %@", date as NSDate)
        ])

        let records = try viewContext.fetch(request)
        for record in records {
            viewContext.delete(record)
        }

        try save()
    }

    /// Удаляет все записи выполнения трекера
    func removeAllRecords(for trackerID: UUID) throws {
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
