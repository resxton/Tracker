import UIKit
import SnapKit

protocol FilterViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

final class FilterViewController: UIViewController {
    
    // MARK: - Visual Components
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = .ypGrey
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorStyle = .singleLine
        tableView.register(FilterCell.self, forCellReuseIdentifier: "FilterCell")
        return tableView
    }()
    
    // MARK: - Private Properties
    
    private let filters: [TrackerFilter] = TrackerFilter.allCases
    private var selectedFilter: TrackerFilter
    weak var delegate: FilterViewControllerDelegate?
    
    // MARK: - Initializers
    
    init(selectedFilter: TrackerFilter) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        navigationItem.title = "Фильтры"
        view.backgroundColor = .ypWhite
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {

        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(filters.count * 75)
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension FilterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as? FilterCell else {
            return UITableViewCell()
        }
        let filter = filters[indexPath.row]
        cell.configure(with: filter.rawValue, isSelected: filter == selectedFilter)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedFilter = filters[indexPath.row]
        delegate?.didSelectFilter(selectedFilter)
        dismiss(animated: true)
    }
}
