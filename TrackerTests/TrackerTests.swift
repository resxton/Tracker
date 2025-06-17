import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testViewControllerLight() {
        guard let diContainer = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.container else {
            assertionFailure("DI Container not found")
            return
        }
        let vc = diContainer.makeMainTabBarController()
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testViewControllerDark() {
        guard let diContainer = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.container else {
            assertionFailure("DI Container not found")
            return
        }
        let vc = diContainer.makeMainTabBarController()
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
