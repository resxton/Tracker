import UIKit
import SnapKit

final class CategoryViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: CategoryViewModel
    private var categories: [TrackerCategory] = []
    var selectedCategory: TrackerCategory? // Сделали доступным
    var onCategorySelected: ((TrackerCategory) -> Void)? // Добавили замыкание

    // MARK: - UI
    private lazy var stubImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "HomeViewStubImage"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = "Привет! Давай создадим первую категорию"
        label.textColor = .ypGrey
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        tableView.separatorStyle = .none
        return tableView
    }()

    // MARK: - Init
    init(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "Категории"

        view.addSubview(stubImageView)
        view.addSubview(stubLabel)
        view.addSubview(addCategoryButton)
        view.addSubview(tableView)

        stubImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50)
        }

        stubLabel.snp.makeConstraints { make in
            make.top.equalTo(stubImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        addCategoryButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(60)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(view.layoutMarginsGuide)
            make.bottom.equalTo(addCategoryButton.snp.top).offset(-8)
        }

        updateUI()
    }

    private func bindViewModel() {
        viewModel.onCategoriesUpdated = { [weak self] categories in
            self?.categories = categories
            self?.updateUI()
            self?.tableView.reloadData()
        }
        viewModel.onError = { error in
            print("Error: \(error.localizedDescription)")
        }
        viewModel.loadCategories()
    }

    private func updateUI() {
        let isEmpty = categories.isEmpty
        stubImageView.isHidden = !isEmpty
        stubLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    // MARK: - Actions
    @objc private func addCategoryButtonTapped() {
        let newVC = NewCategoryViewController()
        newVC.onCategoryCreated = { [weak self] title in
            self?.viewModel.addCategory(title)
        }
        present(newVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        categories.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        let category = categories[indexPath.section]
        cell.configure(with: category.title, isSelected: category.title == selectedCategory?.title)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.section]
        selectedCategory = category
        tableView.reloadData()
        onCategorySelected?(category)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        8
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
}

// MARK: - Custom Cell
class CategoryCell: UITableViewCell {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .ypBlack
        return label
    }()

    private lazy var checkmarkView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .blue
        imageView.isHidden = true
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .ypBackground
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true

        contentView.addSubview(titleLabel)
        contentView.addSubview(checkmarkView)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        checkmarkView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }

    func configure(with title: String, isSelected: Bool) {
        titleLabel.text = title
        checkmarkView.isHidden = !isSelected
    }
}
