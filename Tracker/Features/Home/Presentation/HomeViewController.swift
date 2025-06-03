import UIKit
import SnapKit

final class HomeViewController: UIViewController {
    
    // MARK: - Visual Components
    
    private let stubView: UIStackView = {
        guard let image = UIImage(named: Constants.stubImage) else {
            fatalError("[HomeViewController] – Не существует картинки-заглушки")
        }

        let stubLabel = UILabel()
        stubLabel.text = Constants.stubMessage
        stubLabel.textAlignment = .center
        stubLabel.font = .systemFont(ofSize: Constants.stubTitleFontSize)
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        
        let stack = UIStackView(arrangedSubviews: [imageView, stubLabel])
        stack.axis = .vertical
        stack.spacing = Constants.Layout.stubSpacing
        stack.alignment = .center
        
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(Constants.Layout.stubImageWidth)
        }
        
        return stack
    }()
    
    // MARK: - Private Properties

    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate = Date()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItems()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationItems() {
        guard let leftNavIcon = UIImage(named: Constants.addButtonIcon)?
            .withRenderingMode(.alwaysTemplate)
            .withTintColor(.ypBlack) else {
            fatalError("[HomeViewController] – Не существует картинки для left nav item")
        }
        
        navigationItem.title = Constants.title
        
        let searchController = UISearchController()
        navigationItem.searchController = searchController
        
        let addButton = UIBarButtonItem(
            image: leftNavIcon,
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationItem.leftBarButtonItem = addButton
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        
        datePicker.snp.makeConstraints { make in
            make.width.equalTo(Constants.Layout.datePickerWidth)
        }
        
        let rightNavItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = rightNavItem
    }
    
    @objc private func addButtonTapped() {
        // TODO: Реализовать функционал кнопки добавления трекера
        print("Add button tapped")
    }
    
    private func setupUI() {
        view.addSubview(stubView)
    }
    
    private func setupConstraints() {
        stubView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.layoutMarginsGuide)
            make.centerY.equalTo(view.layoutMarginsGuide.snp.centerY)
        }
    }
}

extension HomeViewController {
    private enum Constants {
        static let title = "Трекеры"
        static let addButtonIcon = "PlusIcon"
        static let stubImage = "HomeViewStubImage"
        static let stubMessage = "Что будем отслеживать?"
        static let stubTitleFontSize: CGFloat = 12
        
        enum Layout {
            static let stubSpacing: CGFloat = 8
            static let stubImageWidth: CGFloat = 80
            static let datePickerWidth: CGFloat = 120
        }
    }
}
