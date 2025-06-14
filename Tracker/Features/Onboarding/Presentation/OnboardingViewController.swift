import UIKit
import SnapKit

final class OnboardingViewController: UIPageViewController {
    
    // MARK: - Visual Components
    
    private lazy var pages: [UIViewController] = {
        let firstOnboarding = PageViewController(page: .first, labelText: "Отслеживайте только то, что хотите")
        let secondOnboarding = PageViewController(page: .second, labelText: "Даже если это не литры воды и йога")
        return [firstOnboarding, secondOnboarding]
    }()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        return pageControl
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(Constants.buttonTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializers
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        dataSource = self
        delegate = self
        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.addSubview(pageControl)
        view.addSubview(button)
    }
    
    private func setupConstraints() {
        button.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.layoutMarginsGuide).inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(50)
            make.height.equalTo(Constants.buttonHeight)
        }
        
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(button.snp.top).offset(-20)
        }
    }
    
    @objc private func buttonTapped() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        guard let sceneDelegate = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive })?
            .delegate as? SceneDelegate else {
            print("Ошибка: SceneDelegate не найден")
            return
        }
        
        sceneDelegate.switchToHome()
    }
}

// MARK: - UIPageViewControllerDelegate & UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else {
            return nil
        }
        return pages[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let currentVC = pageViewController.viewControllers?.first, let index = pages.firstIndex(of: currentVC) {
            pageControl.currentPage = index
        }
    }
}

// MARK: - Types

extension OnboardingViewController {
    private enum Constants {
        static let buttonTitle = "Вот это технологии!"
        static let buttonHeight: CGFloat = 60
    }
}
