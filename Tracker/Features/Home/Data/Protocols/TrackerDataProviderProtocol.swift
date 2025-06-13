import Foundation

protocol TrackerDataProviderProtocol: AnyObject {
    var delegate: TrackerDataProviderDelegate? { get set }
    var numberOfSections: Int { get }
    func numberOfItems(in section: Int) -> Int
    func tracker(at indexPath: IndexPath) -> Tracker?
    func titleForSection(_ section: Int) -> String?
    func updateFilter(schedule: Schedule?, searchText: String?)
}
