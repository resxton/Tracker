import CoreData

final class TrackerDataProvider: NSObject {
    
    // MARK: - Public Properties
    
    weak var delegate: TrackerDataProviderDelegate?
    
    // MARK: - Private Properties
    
    private let fetchedResultsController: NSFetchedResultsController<TrackerCD>
    private let viewContext: NSManagedObjectContext
    private var filterScheduleMask: Int64? = nil

    // MARK: - Initializers
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context

        let request: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
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

        super.init()
        self.fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            print("FetchedResultsController fetch performed successfully")
        } catch {
            print("Failed to perform fetch: \(error)")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerDataProvider: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("NSFetchedResultsController content did change")
        delegate?.didChangeContent()
    }
}

// MARK: - TrackerDataProviderProtocol

extension TrackerDataProvider: TrackerDataProviderProtocol {
    var numberOfSections: Int {
        let count = fetchedResultsController.sections?.count ?? 0
        print("Number of sections requested: \(count)")
        return count
    }

    func numberOfItems(in section: Int) -> Int {
        let count = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        print("Number of items in section \(section): \(count)")
        return count
    }

    func tracker(at indexPath: IndexPath) -> Tracker? {
        let cdTracker = fetchedResultsController.object(at: indexPath)
        let domainTracker = cdTracker.toDomain()
        print("Tracker requested at \(indexPath): \(domainTracker?.name ?? "nil")")
        return domainTracker
    }

    func titleForSection(_ section: Int) -> String? {
        let title = fetchedResultsController.sections?[section].name
        print("Title for section \(section): \(title ?? "nil")")
        return title
    }
    
    func updateFilter(schedule: Schedule?, searchText: String?) {
        var predicates: [NSPredicate] = []
        
        if let schedule = schedule, !schedule.isEmpty {
            filterScheduleMask = Int64(schedule.rawValue)
            predicates.append(NSPredicate(format: "schedule & %d != 0", filterScheduleMask!))
        } else {
            filterScheduleMask = nil
        }
        
        if let searchText = searchText, !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", searchText))
        }
        
        if predicates.isEmpty {
            fetchedResultsController.fetchRequest.predicate = nil
        } else {
            fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        do {
            try fetchedResultsController.performFetch()
            delegate?.didChangeContent()
        } catch {
            print("Failed to perform fetch with filter: \(error)")
        }
    }
}
