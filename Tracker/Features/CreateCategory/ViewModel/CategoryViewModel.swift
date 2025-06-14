import Foundation

class CategoryViewModel {
    
    // MARK: - Public Properties
    
    var onCategoriesUpdated: (([TrackerCategory]) -> Void)?
    var onError: ((Error) -> Void)?
    var onCategorySelected: ((TrackerCategory) -> Void)?
    var categories: [TrackerCategory] = []

    // MARK: - Private Properties
    
    private let store: TrackerCategoryStore
    private var selectedCategory: TrackerCategory? {
        didSet {
            if let selected = selectedCategory {
                onCategorySelected?(selected)
            }
        }
    }

    // MARK: - Initializers
    
    init(store: TrackerCategoryStore) {
        self.store = store
        loadCategories()
    }

    // MARK: - Public Methods
    
    func numberOfSections() -> Int {
        categories.count
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

    func selectCategory(at index: Int) {
        guard index < categories.count else { return }
        selectedCategory = categories[index]
    }

    func isCategorySelected(at index: Int) -> Bool {
        guard index < categories.count else { return false }
        return categories[index].title == selectedCategory?.title
    }
}
