import CoreData

protocol TrackerCategoryDataProviderDelegate: AnyObject {
    func didUpdateCategories(_ categories: [TrackerCategory])
}

final class TrackerCategoryDataProvider: NSObject {
    private let fetchedResultsController: NSFetchedResultsController<TrackerCategoryCD>
    weak var delegate: TrackerCategoryDataProviderDelegate?

    var fetchedCategories: [TrackerCategory] {
        (fetchedResultsController.fetchedObjects ?? []).compactMap { $0.toDomain() }
    }

    init(context: NSManagedObjectContext) {
        let request: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        self.fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
    }
}

extension TrackerCategoryDataProvider: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategories(fetchedCategories)
    }
}
