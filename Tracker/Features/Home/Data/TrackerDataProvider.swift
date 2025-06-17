import CoreData

final class TrackerDataProvider: NSObject {
    
    // MARK: - Public Properties
    
    weak var delegate: TrackerDataProviderDelegate?
    
    // MARK: - Private Properties
    
    private let fetchedResultsController: NSFetchedResultsController<TrackerCD>
    private let pinnedFetchRequest: NSFetchRequest<TrackerCD>
    private let viewContext: NSManagedObjectContext
    private var filterScheduleMask: Int64? = nil
    private var pinnedTrackers: [TrackerCD] = []

    // MARK: - Initializers
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context

        // Основной запрос для незакрепленных трекеров
        let request: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "isPinned == false") // Исключаем закрепленные трекеры
        request.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]

        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )

        // Запрос для закрепленных трекеров
        self.pinnedFetchRequest = TrackerCD.fetchRequest()
        pinnedFetchRequest.predicate = NSPredicate(format: "isPinned == true")
        pinnedFetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]

        super.init()
        self.fetchedResultsController.delegate = self
        fetchPinnedTrackers()
        do {
            try fetchedResultsController.performFetch()
            print("FetchedResultsController fetch performed successfully")
        } catch {
            print("Failed to perform fetch: \(error)")
        }
    }

    // MARK: - Private Methods

    private func fetchPinnedTrackers() {
        do {
            pinnedTrackers = try viewContext.fetch(pinnedFetchRequest)
            print("Fetched \(pinnedTrackers.count) pinned trackers")
        } catch {
            print("Failed to fetch pinned trackers: \(error)")
            pinnedTrackers = []
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerDataProvider: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("NSFetchedResultsController content did change")
        fetchPinnedTrackers() // Обновляем закрепленные трекеры при изменении данных
        delegate?.didChangeContent()
    }
}

// MARK: - TrackerDataProviderProtocol

extension TrackerDataProvider: TrackerDataProviderProtocol {
    var numberOfSections: Int {
        let baseSections = fetchedResultsController.sections?.count ?? 0
        let hasPinned = !pinnedTrackers.isEmpty
        let totalSections = baseSections + (hasPinned ? 1 : 0)
        print("Number of sections requested: \(totalSections)")
        return totalSections
    }

    func numberOfItems(in section: Int) -> Int {
        if section == 0 && !pinnedTrackers.isEmpty {
            let count = pinnedTrackers.count
            print("Number of items in pinned section: \(count)")
            return count
        }
        let adjustedSection = !pinnedTrackers.isEmpty ? section - 1 : section
        let count = fetchedResultsController.sections?[adjustedSection].numberOfObjects ?? 0
        print("Number of items in section \(section): \(count)")
        return count
    }

    func tracker(at indexPath: IndexPath) -> Tracker? {
        if indexPath.section == 0 && !pinnedTrackers.isEmpty {
            let cdTracker = pinnedTrackers[indexPath.row]
            let domainTracker = cdTracker.toDomain()
            print("Pinned tracker requested at \(indexPath): \(domainTracker?.name ?? "nil")")
            return domainTracker
        }
        let adjustedSection = !pinnedTrackers.isEmpty ? indexPath.section - 1 : indexPath.section
        let adjustedIndexPath = IndexPath(row: indexPath.row, section: adjustedSection)
        let cdTracker = fetchedResultsController.object(at: adjustedIndexPath)
        let domainTracker = cdTracker.toDomain()
        print("Tracker requested at \(indexPath): \(domainTracker?.name ?? "nil")")
        return domainTracker
    }

    func titleForSection(_ section: Int) -> String? {
        if section == 0 && !pinnedTrackers.isEmpty {
            print("Title for pinned section: \(Constants.pinnedCategoryTitle)")
            return Constants.pinnedCategoryTitle
        }
        let adjustedSection = !pinnedTrackers.isEmpty ? section - 1 : section
        let title = fetchedResultsController.sections?[adjustedSection].name
        let finalTitle = title == "" ? Constants.defaultCategoryTitle : title
        print("Title for section \(section): \(finalTitle ?? "nil")")
        return finalTitle
    }
    
    func updateFilter(schedule: Schedule?, searchText: String?) {
        var predicates: [NSPredicate] = []
        var pinnedPredicates: [NSPredicate] = [NSPredicate(format: "isPinned == true")]
        
        if let schedule = schedule, !schedule.isEmpty {
            filterScheduleMask = Int64(schedule.rawValue)
            predicates.append(NSPredicate(format: "schedule & %d != 0", filterScheduleMask!))
            pinnedPredicates.append(NSPredicate(format: "schedule & %d != 0", filterScheduleMask!))
        } else {
            filterScheduleMask = nil
        }
        
        if let searchText = searchText, !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", searchText))
            pinnedPredicates.append(NSPredicate(format: "name CONTAINS[cd] %@", searchText))
        }
        
        // Основной запрос (незакрепленные трекеры)
        if predicates.isEmpty {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "isPinned == false")
        } else {
            predicates.append(NSPredicate(format: "isPinned == false"))
            fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        // Запрос для закрепленных трекеров
        if pinnedPredicates.count == 1 {
            pinnedFetchRequest.predicate = NSPredicate(format: "isPinned == true")
        } else {
            pinnedFetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: pinnedPredicates)
        }

        do {
            try fetchedResultsController.performFetch()
            fetchPinnedTrackers()
            delegate?.didChangeContent()
        } catch {
            print("Failed to perform fetch with filter: \(error)")
        }
    }

    // MARK: - Constants

    private enum Constants {
        static let pinnedCategoryTitle = "Закрепленные"
        static let defaultCategoryTitle = "Общее"
    }
}
