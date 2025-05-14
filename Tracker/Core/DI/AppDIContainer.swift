import UIKit

final class AppDIContainer {
    
    // MARK: - Public Methods
    
    public func makeHomeViewController() -> UINavigationController {
        guard let tabIcon = UIImage(named: Constants.homeViewTabIcon)?
            .withRenderingMode(.alwaysTemplate) else {
            fatalError("[AppDIContainer] – Не существует картинки для таба HomeView")
        }
        
        let homeView = HomeViewController()
        homeView.tabBarItem = UITabBarItem(
            title: Constants.homeViewTabTitle,
            image: tabIcon,
            selectedImage: tabIcon
        )
        
        let navigationController = UINavigationController(rootViewController: homeView)
        navigationController.navigationBar.prefersLargeTitles = true
        
        return navigationController
    }
    
    public func makeStatsViewController() -> StatsViewController {
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
}

extension AppDIContainer {
    private enum Constants {
        static let homeViewTabTitle = "Трекеры"
        static let statsViewTabTitle = "Статистика"
        static let homeViewTabIcon = "TrackerTabIcon"
        static let statsViewTabIcon = "StatsTabIcon"
    }
}
