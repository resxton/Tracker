import UIKit
import SnapKit

final class CategoryViewController: UIViewController {
    
    // MARK: - Visual Components
    
    private lazy var stubImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "HomeViewStubImage"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно объединить по смыслу"
        label.textColor = .ypGrey
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
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
    
    // MARK: - Public Properties
    
    var selectedCategory: TrackerCategory? {
        didSet {
            viewModel
                .selectCategory(
                    at: viewModel.categories.firstIndex(
                        where: {
                            $0.title == selectedCategory?.title
                        }) ?? 0
                )
        }
    }
    
    var onCategorySelected: ((TrackerCategory) -> Void)? {
        didSet {
            viewModel.onCategorySelected = onCategorySelected
        }
    }
    
    // MARK: - Private Properties
    
    private let viewModel: CategoryViewModel
    
    // MARK: - Initializers
    
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
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
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
            self?.updateUI()
            self?.tableView.reloadData()
        }
        viewModel.onError = { error in
            print("Error: \(error.localizedDescription)")
        }
        viewModel.loadCategories()
    }
    
    private func updateUI() {
        let isEmpty = viewModel.categories.isEmpty
        stubImageView.isHidden = !isEmpty
        stubLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
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
        viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        let category = viewModel.categories[indexPath.section]
        cell.configure(with: category.title, isSelected: viewModel.isCategorySelected(at: indexPath.section))
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.section)
        tableView.reloadData()
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
