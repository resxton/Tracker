import UIKit

class CategoryViewModel {
    private var categories: [TrackerCategory] = []
    private let store: TrackerCategoryStore
    var onCategoriesUpdated: (([TrackerCategory]) -> Void)?
    var onError: ((Error) -> Void)?
    
    init(store: TrackerCategoryStore) {
        self.store = store
        loadCategories()
    }
    
    func loadCategories() {
        do {
            categories = try store.fetchAll()
            onCategoriesUpdated?(categories)
        } catch {
            onError?(error)
        }
    }
    
    func addCategory(_ title: String) {
        let newCategory = TrackerCategory(title: title, trackers: [])
        do {
            try store.create(newCategory)
            loadCategories()
        } catch {
            onError?(error)
        }
    }
    
    func deleteCategory(at index: Int) {
        guard index < categories.count else { return }
        let category = categories[index]
        do {
            try store.delete(category)
            loadCategories()
        } catch {
            onError?(error)
        }
    }
}
