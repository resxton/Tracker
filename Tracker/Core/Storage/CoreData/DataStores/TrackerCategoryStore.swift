import CoreData

final class TrackerCategoryStore {
    // MARK: - Private Properties
    private let coreDataStack: CoreDataStack
    private var viewContext: NSManagedObjectContext {
        coreDataStack.viewContext
    }
    private lazy var trackerStore: TrackerStore = {
        .init(coreDataStack: coreDataStack)
    }()

    // MARK: - Initializers
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    // MARK: - Public Methods
    func create(_ category: TrackerCategory) throws {
        let request: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", category.title)
        let existingCategories = try viewContext.fetch(request)
        guard existingCategories.isEmpty else {
            throw NSError(domain: "TrackerCategoryStore", code: 409, userInfo: [NSLocalizedDescriptionKey: "Category with this title already exists"])
        }

        let categoryCD = TrackerCategoryCD(context: viewContext)
        categoryCD.title = category.title

        let trackerCDs = category.trackers.map { tracker -> TrackerCD in
            let trackerCD = TrackerCD(context: viewContext)
            trackerCD.id = tracker.id
            trackerCD.name = tracker.name
            trackerCD.color = tracker.color
            trackerCD.emoji = tracker.emoji
            trackerCD.schedule = Int64(tracker.schedule.rawValue)
            trackerCD.category = categoryCD
            return trackerCD
        }

        categoryCD.addToTrackers(NSSet(array: trackerCDs))
        try save()
    }

    func fetchAll() throws -> [TrackerCategory] {
        let request: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        let categoriesCD = try viewContext.fetch(request)
        return categoriesCD.compactMap { $0.toDomain() }
    }

    func update(_ category: TrackerCategory) throws {
        let request: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", category.title)

        guard let categoryCD = try viewContext.fetch(request).first else {
            throw NSError(domain: "TrackerCategoryStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Category not found"])
        }

        let existingTrackerIDs = (categoryCD.trackers?.allObjects as? [TrackerCD])?.compactMap { $0.id } ?? []
        let newTrackerIDs = category.trackers.map { $0.id }
        let trackersToDelete = existingTrackerIDs.filter { !newTrackerIDs.contains($0) }

        for case let trackerCD as TrackerCD in categoryCD.trackers ?? [] where trackersToDelete.contains(trackerCD.id ?? UUID()) {
            viewContext.delete(trackerCD)
        }

        let newTrackerCDs = category.trackers.map { tracker -> TrackerCD in
            let trackerCD = TrackerCD(context: viewContext)
            trackerCD.id = tracker.id
            trackerCD.name = tracker.name
            trackerCD.color = tracker.color
            trackerCD.emoji = tracker.emoji
            trackerCD.schedule = Int64(tracker.schedule.rawValue)
            trackerCD.category = categoryCD
            return trackerCD
        }

        categoryCD.trackers = NSSet(array: newTrackerCDs)
        try save()
    }

    func delete(_ category: TrackerCategory) throws {
        let request: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", category.title)

        let categories = try viewContext.fetch(request)
        for category in categories {
            viewContext.delete(category)
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
