import UIKit

final class AppDIContainer {
    
    // MARK: - Private Properties
    
    private let coreDataStack = CoreDataStack()
    private lazy var trackerStore: TrackerStore = {
        TrackerStore(coreDataStack: coreDataStack)
    }()
    private lazy var trackerCategoryStore: TrackerCategoryStore = {
        TrackerCategoryStore(coreDataStack: coreDataStack)
    }()
    private lazy var trackerRecordStore: TrackerRecordStore = {
        TrackerRecordStore(coreDataStack: coreDataStack)
    }()
    private lazy var trackerDataProvider: TrackerDataProviderProtocol = {
        TrackerDataProvider(context: coreDataStack.viewContext)
    }()
    
    // MARK: - Public Methods
    
    func makeOnboardingViewController() -> OnboardingViewController {
        OnboardingViewController()
    }
    
    func makeHomeViewController() -> UINavigationController {
        guard let tabIcon = UIImage(named: Constants.homeViewTabIcon)?
            .withRenderingMode(.alwaysTemplate) else {
            fatalError("[AppDIContainer] – Не существует картинки для таба HomeView")
        }
        
        let homeView = HomeViewController(
            trackerStore: trackerStore,
            trackerCategoryStore: trackerCategoryStore,
            trackerRecordStore: trackerRecordStore,
            trackerDataProvider: trackerDataProvider
        )
        
        homeView.tabBarItem = UITabBarItem(
            title: Constants.homeViewTabTitle,
            image: tabIcon,
            selectedImage: tabIcon
        )
        
        let navigationController = UINavigationController(rootViewController: homeView)
        navigationController.navigationBar.prefersLargeTitles = true
        
        return navigationController
    }
    
    func makeStatsViewController() -> StatsViewController {
        guard let tabIcon = UIImage(named: Constants.statsViewTabIcon)?
            .withRenderingMode(.alwaysTemplate) else {
            fatalError("[AppDIContainer] – Не существует картинки для таба StatsView")
        }
        
        let statsView = StatsViewController()
        statsView.tabBarItem = UITabBarItem(
            title: Constants.statsViewTabTitle,
            image: tabIcon,
            selectedImage: tabIcon
        )
        
        return statsView
    }
    
    func makeMainTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            makeHomeViewController(),
            makeStatsViewController()
        ]
        
        return tabBarController
    }
    
    func makeCategoryViewController() -> UINavigationController {
        let viewModel = CategoryViewModel(store: trackerCategoryStore)
        let categoryVC = CategoryViewController(viewModel: viewModel)
        let navController = UINavigationController(rootViewController: categoryVC)
        return navController
    }
}

// MARK: - Constants

extension AppDIContainer {
    private enum Constants {
        static let homeViewTabTitle = "Трекеры"
        static let statsViewTabTitle = "Статистика"
        static let homeViewTabIcon = "TrackerTabIcon"
        static let statsViewTabIcon = "StatsTabIcon"
    }
}
