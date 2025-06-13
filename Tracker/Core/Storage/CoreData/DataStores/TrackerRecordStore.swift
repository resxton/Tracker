import CoreData

final class TrackerRecordStore {
    
    // MARK: - Private Properties
    
    private let coreDataStack: CoreDataStack
    private var viewContext: NSManagedObjectContext {
        coreDataStack.viewContext
    }
    
    // MARK: - Initializers
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - Public Methods

    func addRecord(for trackerID: UUID, on date: Date) throws {
        let normalizedDate = date.startOfDay()
        guard try !isRecordExist(for: trackerID, on: normalizedDate) else { return }
        
        let trackerRequest: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        trackerRequest.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)

        guard let trackerCD = try viewContext.fetch(trackerRequest).first else {
            throw NSError(domain: "TrackerRecordStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Tracker not found"])
        }

        let recordCD = TrackerRecordCD(context: viewContext)
        recordCD.id = UUID()
        recordCD.date = normalizedDate
        recordCD.tracker = trackerCD

        try save()
    }
    
    func isRecordExist(for trackerID: UUID, on date: Date) throws -> Bool {
        let normalizedDate = date.startOfDay()
        let request: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "tracker.id == %@", trackerID as CVarArg),
            NSPredicate(format: "date == %@", normalizedDate as NSDate)
        ])
        let count = try viewContext.count(for: request)
        return count > 0
    }

    func countRecords(for trackerID: UUID) throws -> Int {
        let request: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        request.predicate = NSPredicate(format: "tracker.id == %@", trackerID as CVarArg)
        let count = try viewContext.count(for: request)
        return count
    }

    func removeRecord(for trackerID: UUID, on date: Date) throws {
        let normalizedDate = date.startOfDay()
        let request: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "tracker.id == %@", trackerID as CVarArg),
            NSPredicate(format: "date == %@", normalizedDate as NSDate)
        ])

        let records = try viewContext.fetch(request)
        for record in records {
            viewContext.delete(record)
        }

        try save()
    }

    func removeAllRecords(for trackerID: UUID) throws {
        let request: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        request.predicate = NSPredicate(format: "tracker.id == %@", trackerID as CVarArg)

        let records = try viewContext.fetch(request)
        for record in records {
            viewContext.delete(record)
        }

        try save()
    }
    
    // MARK: - Private Methods

    private func save() throws {
        if viewContext.hasChanges {
            try viewContext.save()
        }
    }
}
