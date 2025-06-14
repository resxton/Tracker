import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let container = AppDIContainer()
    let alwaysShowOnboarding: Bool = true

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        
        let rootViewController = alwaysShowOnboarding ? OnboardingViewController() : (
            hasSeenOnboarding ? container.makeMainTabBarController() : OnboardingViewController()
        )
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .ypWhite
        tabBarAppearance.shadowColor = UIColor(white: 0, alpha: 0.5)

        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        
        UINavigationBar.appearance().tintColor = .ypBlack
        
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
    
    func switchToHome() {
        guard let window = window else { return }
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            let tabBarController = self.container.makeMainTabBarController()
            window.rootViewController = tabBarController
        }, completion: nil)
    }
}
