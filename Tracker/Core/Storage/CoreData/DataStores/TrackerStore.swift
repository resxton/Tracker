import CoreData

final class TrackerStore {
    
    // MARK: - Private Properties
    
    private let coreDataStack: CoreDataStack
    private var viewContext: NSManagedObjectContext {
        coreDataStack.viewContext
    }
    
    // MARK: - Initializers

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
        print("TrackerStore initialized")
    }

    // MARK: - Public Methods

    func addTracker(_ tracker: Tracker, to categoryTitle: String) throws {
        print("Add tracker '\(tracker.name)' to category '\(categoryTitle)'")
        let category = try findOrCreateCategory(named: categoryTitle)
        try create(tracker, category: category)
        print("Tracker '\(tracker.name)' added successfully")
    }

    func create(_ tracker: Tracker, category: TrackerCategoryCD? = nil) throws {
        print("Creating tracker '\(tracker.name)' in Core Data")
        let trackerCD = TrackerCD(context: viewContext)
        trackerCD.id = tracker.id
        trackerCD.name = tracker.name
        trackerCD.color = tracker.color
        trackerCD.emoji = tracker.emoji
        trackerCD.schedule = Int64(tracker.schedule.rawValue)
        trackerCD.category = category
        trackerCD.isPinned = tracker.isPinned

        try save()
        print("Tracker '\(tracker.name)' saved")
    }

    func fetchAll() throws -> [Tracker] {
        print("Fetching all trackers")
        let request: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        let trackerCDs = try viewContext.fetch(request)
        print("Fetched \(trackerCDs.count) trackers")
        return trackerCDs.compactMap { $0.toDomain() }
    }

    func fetch(by id: UUID) throws -> Tracker? {
        print("Fetching tracker by id: \(id)")
        let request: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        let result = try viewContext.fetch(request).first?.toDomain()
        if result != nil {
            print("Tracker found")
        } else {
            print("Tracker not found")
        }
        return result
    }

    func update(_ tracker: Tracker) throws {
        print("Updating tracker '\(tracker.name)'")
        let request: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        request.fetchLimit = 1

        guard let trackerCD = try viewContext.fetch(request).first else {
            print("Tracker to update not found")
            throw NSError(domain: "TrackerStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Tracker not found"])
        }

        trackerCD.name = tracker.name
        trackerCD.color = tracker.color
        trackerCD.emoji = tracker.emoji
        trackerCD.schedule = Int64(tracker.schedule.rawValue)
        trackerCD.isPinned = tracker.isPinned
        if let categoryTitle = tracker.categoryTitle {
            trackerCD.category = try findOrCreateCategory(named: categoryTitle)
        }

        try save()
        print("Tracker '\(tracker.name)' updated")
    }

    func delete(_ tracker: Tracker) throws {
        print("Deleting tracker '\(tracker.name)'")
        let request: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)

        let trackerCDs = try viewContext.fetch(request)
        trackerCDs.forEach { viewContext.delete($0) }

        try save()
        print("Tracker '\(tracker.name)' deleted")
    }
    
    func deleteAll() throws {
        let request: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        
        if let trackerCDs = try? viewContext.fetch(request) {
            trackerCDs.forEach { viewContext.delete($0) }
        }
        
        try save()
        print("All trackers deleted")
    }

    func pinTracker(_ tracker: Tracker) throws {
        print("Pinning tracker '\(tracker.name)'")
        let request: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        request.fetchLimit = 1

        guard let trackerCD = try viewContext.fetch(request).first else {
            print("Tracker to pin not found")
            throw NSError(domain: "TrackerStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Tracker not found"])
        }

        trackerCD.isPinned = true

        try save()
        print("Tracker '\(tracker.name)' pinned")
    }

    func unpinTracker(_ tracker: Tracker) throws {
        print("Unpinning tracker '\(tracker.name)'")
        let request: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        request.fetchLimit = 1

        guard let trackerCD = try viewContext.fetch(request).first else {
            print("Tracker to unpin not found")
            throw NSError(domain: "TrackerStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Tracker not found"])
        }

        trackerCD.isPinned = false

        try save()
        print("Tracker '\(tracker.name)' unpinned")
    }
    
    func fetchTrackersCount() throws -> Int {
        let request: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        return try viewContext.count(for: request)
    }

    // MARK: - Private Methods

    private func findOrCreateCategory(named title: String) throws -> TrackerCategoryCD {
        print("Searching category with title '\(title)'")
        let request: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1

        if let existing = try viewContext.fetch(request).first {
            print("Found existing category '\(title)'")
            return existing
        }

        print("Creating new category '\(title)'")
        let newCategory = TrackerCategoryCD(context: viewContext)
        newCategory.title = title
        return newCategory
    }

    private func save() throws {
        if viewContext.hasChanges {
            print("Saving context")
            try viewContext.save()
            print("Context saved")
        } else {
            print("No changes to save")
        }
    }
}
