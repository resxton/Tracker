import UIKit
import SnapKit

final class HomeViewController: UIViewController {
    
    // MARK: - Visual Components
    
    private let stubView: UIStackView = {
        guard let image = UIImage(named: Constants.stubImage) else {
            fatalError("[HomeViewController] – Не существует картинки-заглушки")
        }

        let stubLabel = UILabel()
        stubLabel.text = Constants.stubTitle
        stubLabel.textAlignment = .center
        stubLabel.font = .systemFont(ofSize: Constants.stubTitleFontSize)
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        
        let stack = UIStackView(arrangedSubviews: [imageView, stubLabel])
        stack.axis = .vertical
        stack.spacing = Constants.stubSpacing
        stack.alignment = .center
        
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(Constants.stubImageSize)
        }
        
        return stack
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItems()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationItems() {
        guard let leftNavIcon = UIImage(named: Constants.leftNavItemIcon)?
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
        static let leftNavItemIcon = "PlusIcon"
        static let stubImage = "HomeViewStubImage"
        static let stubTitle = "Что будем отслеживать?"
        static let stubSpacing: CGFloat = 8
        static let stubTitleFontSize: CGFloat = 12
        static let stubImageSize: CGFloat = 80
    }
}
