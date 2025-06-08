import CoreData

protocol TrackerDataProviderProtocol: AnyObject {
    var delegate: TrackerDataProviderDelegate? { get set }
    var numberOfSections: Int { get }
    func numberOfItems(in section: Int) -> Int
    func tracker(at indexPath: IndexPath) -> Tracker?
    func titleForSection(_ section: Int) -> String?
    func updateFilter(schedule: Schedule?)
}

protocol TrackerDataProviderDelegate: AnyObject {
    func didChangeContent()
}

final class TrackerDataProvider: NSObject {
    private let fetchedResultsController: NSFetchedResultsController<TrackerCD>
    private let viewContext: NSManagedObjectContext
    private var filterScheduleMask: Int64? = nil

    weak var delegate: TrackerDataProviderDelegate?

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

extension TrackerDataProvider: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("NSFetchedResultsController content did change")
        delegate?.didChangeContent()
    }
}

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
    
    func updateFilter(schedule: Schedule?) {
        if let schedule = schedule {
            filterScheduleMask = Int64(schedule.rawValue)
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "schedule & %d != 0", filterScheduleMask!)
        } else {
            filterScheduleMask = nil
            fetchedResultsController.fetchRequest.predicate = nil
        }
        do {
            try fetchedResultsController.performFetch()
            delegate?.didChangeContent()
        } catch {
            print("Failed to perform fetch with filter: \(error)")
        }
    }
}
