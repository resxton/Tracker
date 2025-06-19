import UIKit
import SnapKit

protocol TrackerTypeViewControllerDelegate: AnyObject {
    func trackerTypeViewController(_ viewController: TrackerTypeViewController, didSelect type: TrackerType)
}

final class TrackerTypeViewController: UIViewController {
    
    // MARK: - Visual Components
    
    private lazy var habitButton: UIButton = {
        let button = UIButton()
        button.setTitle(TrackerType.habit.normalTitle, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var irregularEventButton: UIButton = {
        let button = UIButton()
        button.setTitle(TrackerType.irregularEvent.normalTitle, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    
    weak var delegate: TrackerTypeViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        navigationItem.title = "Создание трекера"
        
        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
            navigationBar.standardAppearance = appearance
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        
        view.addSubview(habitButton)
        view.addSubview(irregularEventButton)
        
        habitButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(295)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
        
        irregularEventButton.snp.makeConstraints { make in
            make.top.equalTo(habitButton.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
    }
    
    @objc private func habitButtonTapped() {
        delegate?.trackerTypeViewController(self, didSelect: .habit)
    }
    
    @objc private func irregularEventButtonTapped() {
        delegate?.trackerTypeViewController(self, didSelect: .irregularEvent)
    }
} 
