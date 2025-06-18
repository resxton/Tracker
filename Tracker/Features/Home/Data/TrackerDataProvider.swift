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
    private let trackerRecordStore: TrackerRecordStore

    // MARK: - Initializers
    
    init(context: NSManagedObjectContext, trackerRecordStore: TrackerRecordStore) {
        self.viewContext = context
        self.trackerRecordStore = trackerRecordStore

        let request: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "isPinned == false")
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
        } catch {
            print("Failed to perform fetch: \(error)")
        }
    }

    // MARK: - Private Methods

    private func fetchPinnedTrackers() {
        do {
            pinnedTrackers = try viewContext.fetch(pinnedFetchRequest)
        } catch {
            print("Failed to fetch pinned trackers: \(error)")
            pinnedTrackers = []
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerDataProvider: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        fetchPinnedTrackers()
        delegate?.didChangeContent()
    }
}

// MARK: - TrackerDataProviderProtocol

extension TrackerDataProvider: TrackerDataProviderProtocol {
    var numberOfSections: Int {
        let baseSections = fetchedResultsController.sections?.count ?? 0
        let hasPinned = !pinnedTrackers.isEmpty
        return baseSections + (hasPinned ? 1 : 0)
    }

    func numberOfItems(in section: Int) -> Int {
        if section == 0 && !pinnedTrackers.isEmpty {
            return pinnedTrackers.count
        }
        let adjustedSection = !pinnedTrackers.isEmpty ? section - 1 : section
        return fetchedResultsController.sections?[adjustedSection].numberOfObjects ?? 0
    }

    func tracker(at indexPath: IndexPath) -> Tracker? {
        if indexPath.section == 0 && !pinnedTrackers.isEmpty {
            let cdTracker = pinnedTrackers[indexPath.row]
            return cdTracker.toDomain()
        }
        let adjustedSection = !pinnedTrackers.isEmpty ? indexPath.section - 1 : indexPath.section
        let adjustedIndexPath = IndexPath(row: indexPath.row, section: adjustedSection)
        let cdTracker = fetchedResultsController.object(at: adjustedIndexPath)
        return cdTracker.toDomain()
    }

    func titleForSection(_ section: Int) -> String? {
        if section == 0 && !pinnedTrackers.isEmpty {
            return Constants.pinnedCategoryTitle
        }
        let adjustedSection = !pinnedTrackers.isEmpty ? section - 1 : section
        let title = fetchedResultsController.sections?[adjustedSection].name
        return title == "" ? Constants.defaultCategoryTitle : title
    }
    
    func updateFilter(schedule: Schedule?, searchText: String?, filter: TrackerFilter?, date: Date) {
        var predicates: [NSPredicate] = [NSPredicate(format: "isPinned == false")]
        var pinnedPredicates: [NSPredicate] = [NSPredicate(format: "isPinned == true")]
        
        if let schedule = schedule, !schedule.isEmpty, (filter == .today || filter == .all) {
            filterScheduleMask = Int64(schedule.rawValue)
            predicates.append(NSPredicate(format: "schedule & %d != 0", filterScheduleMask!))
            pinnedPredicates.append(NSPredicate(format: "schedule & %d != 0", filterScheduleMask!))
        }
        if let searchText = searchText, !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", searchText))
            pinnedPredicates.append(NSPredicate(format: "name CONTAINS[cd] %@", searchText))
        }
        
        if let filter = filter {
            switch filter {
            case .all, .today:
                break
            case .completed:
                let completedIDs = try? trackerRecordStore.getTrackerIDsWithRecords(on: date)
                if let ids = completedIDs, !ids.isEmpty {
                    predicates.append(NSPredicate(format: "id IN %@", ids))
                    pinnedPredicates.append(NSPredicate(format: "id IN %@", ids))
                } else {
                    predicates.append(NSPredicate(format: "FALSEPREDICATE"))
                    pinnedPredicates.append(NSPredicate(format: "FALSEPREDICATE"))
                }
            case .notCompleted:
                let completedIDs = try? trackerRecordStore.getTrackerIDsWithRecords(on: date)
                if let ids = completedIDs, !ids.isEmpty {
                    predicates.append(NSPredicate(format: "NOT id IN %@", ids))
                    pinnedPredicates.append(NSPredicate(format: "NOT id IN %@", ids))
                }
            }
        }
        
        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        pinnedFetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: pinnedPredicates)

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
