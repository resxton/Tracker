import CoreData

enum TrackerFilter: String, CaseIterable {
    case all = "Все трекеры"
    case today = "Трекеры на сегодня"
    case completed = "Завершенные"
    case notCompleted = "Незавершенные"
}

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

        // Основной запрос для незакрепленных трекеров
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
        fetchPinnedTrackers()
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
    
    func updateFilter(schedule: Schedule?, searchText: String?, filter: TrackerFilter?, date: Date) {
        var predicates: [NSPredicate] = [NSPredicate(format: "isPinned == false")]
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
        
        if let filter = filter {
            switch filter {
            case .all:
                break // Нет дополнительных предикатов
            case .today:
                if let schedule = schedule, !schedule.isEmpty {
                    // Уже добавлен предикат для расписания
                }
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
