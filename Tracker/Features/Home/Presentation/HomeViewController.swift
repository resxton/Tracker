import UIKit
import SnapKit

final class HomeViewController: UIViewController {
    
    // MARK: - Visual Components
    
    private lazy var stubView: UIStackView = {
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
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = Constants.searchPlaceholder
        return controller
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = Constants.Layout.collectionSpacing
        layout.sectionInset = UIEdgeInsets(
            top: Constants.Layout.collectionTopInset,
            left: Constants.Layout.collectionInset,
            bottom: Constants.Layout.sectionBottomInset,
            right: Constants.Layout.collectionInset
        )
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
        collectionView.register(
            HeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: Constants.headerIdentifier
        )
        return collectionView
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Фильтры", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.backgroundColor = .ypBlue
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Private Properties
    
    private let trackerStore: TrackerStore
    private let trackerCategoryStore: TrackerCategoryStore
    private let trackerRecordStore: TrackerRecordStore
    private let trackerDataProvider: TrackerDataProviderProtocol

    private var currentDate = Date().startOfDay()
    private var searchText: String = ""
    private var searchWorkItem: DispatchWorkItem?
    private var selectedFilter: TrackerFilter = .all
    
    // MARK: - Initializers
    
    init(
        trackerStore: TrackerStore,
        trackerCategoryStore: TrackerCategoryStore,
        trackerRecordStore: TrackerRecordStore,
        trackerDataProvider: TrackerDataProviderProtocol
    ) {
        self.trackerStore = trackerStore
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordStore = trackerRecordStore
        self.trackerDataProvider = trackerDataProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackerDataProvider.delegate = self
        
        setupNavigationItems()
        setupUI()
        setupConstraints()
        updateVisibleCategories()
        updateFilter()
        updateUI()
    }
    
    // MARK: - Private Methods
    
    @objc private func datePickerChanged(_ sender: UIDatePicker) {
        currentDate = sender.date.startOfDay()
        updateFilter()
        updateUI()
    }

    private func setupNavigationItems() {
        guard let leftNavIcon = UIImage(named: Constants.addButtonIcon)?
            .withRenderingMode(.alwaysTemplate)
            .withTintColor(.ypBlack) else {
            fatalError("[HomeViewController] – Не существует картинки для left nav item")
        }
        
        navigationItem.title = Constants.title
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
        datePicker.preferredDatePickerStyle = .compact
        datePicker.tintColor = .ypBlue
        datePicker.clipsToBounds = true
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        datePicker.date = currentDate
        
        datePicker.snp.makeConstraints { make in
            make.width.equalTo(Constants.Layout.datePickerWidth)
        }
        
        datePicker.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
        let rightNavItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = rightNavItem
    }
    
    @objc private func addButtonTapped() {
        let typeViewController = TrackerTypeViewController()
        typeViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: typeViewController)
        present(navigationController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateVisibleCategories()
        updateStubViewVisibility()
    }
    
    @objc private func filterButtonTapped() {
        let filterViewController = FilterViewController(selectedFilter: selectedFilter)
        filterViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: filterViewController)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        view.addSubview(stubView)
        view.addSubview(collectionView)
        view.addSubview(filterButton)
        stubView.isHidden = true
    }
    
    private func setupConstraints() {
        stubView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.layoutMarginsGuide)
            make.centerY.equalTo(view.layoutMarginsGuide.snp.centerY)
        }
        
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.layoutMarginsGuide)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Constants.Layout.collectionTopInset)
        }
        
        filterButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
            make.width.equalTo(114)
            make.height.equalTo(50)
        }
    }
    
    private func updateVisibleCategories() {
        collectionView.reloadData()
    }
    
    private func updateFilter() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        let filterSchedule: Schedule
        
        switch weekday {
        case 1: filterSchedule = .sunday
        case 2: filterSchedule = .monday
        case 3: filterSchedule = .tuesday
        case 4: filterSchedule = .wednesday
        case 5: filterSchedule = .thursday
        case 6: filterSchedule = .friday
        case 7: filterSchedule = .saturday
        default: filterSchedule = .monday
        }
        
        let effectiveSchedule = selectedFilter == .today ? filterSchedule : nil
        trackerDataProvider.updateFilter(schedule: effectiveSchedule, searchText: searchText, filter: selectedFilter, date: currentDate)
    }
    
    private func updateStubViewVisibility() {
        updateUI()
    }
    
    private func updateUI() {
        var hasTrackersForSelectedDate = false
        for section in 0..<trackerDataProvider.numberOfSections {
            if trackerDataProvider.numberOfItems(in: section) > 0 {
                hasTrackersForSelectedDate = true
                break
            }
        }
        
        stubView.isHidden = hasTrackersForSelectedDate
        collectionView.isHidden = !hasTrackersForSelectedDate
    }

    private func performSearch() {
        searchWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.updateFilter()
            self.updateUI()
        }
        
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Layout.searchDebounceDelay, execute: workItem)
    }
    
    // MARK: - Context Menu Actions
    
    private func pinTracker(_ tracker: Tracker) {
        do {
            try trackerStore.pinTracker(tracker)
            collectionView.reloadData()
        } catch {
            print("Ошибка при закреплении трекера: \(error)")
        }
    }
    
    private func unpinTracker(_ tracker: Tracker) {
        do {
            try trackerStore.unpinTracker(tracker)
            collectionView.reloadData()
        } catch {
            print("Ошибка при откреплении трекера: \(error)")
        }
    }
    
    private func editTracker(_ tracker: Tracker) {
        let editViewController = CreateTrackerViewController(type: .habit, trackerStore: trackerStore, trackerRecordStore: trackerRecordStore, editingTracker: tracker)
        let navigationController = UINavigationController(rootViewController: editViewController)
        present(navigationController, animated: true)
    }
    
    private func deleteTracker(_ tracker: Tracker) {
        let alert = UIAlertController(
            title: "Удалить привычку?",
            message: "Вы уверены, что хотите удалить эту привычку?",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            do {
                try self.trackerStore.delete(tracker)
                self.collectionView.reloadData()
                self.updateUI()
            } catch {
                print("Ошибка при удалении трекера: \(error)")
            }
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackerDataProvider.numberOfSections
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return trackerDataProvider.numberOfItems(in: section)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Constants.cellIdentifier,
            for: indexPath
        ) as? TrackerCell else {
            assertionFailure("Failed to dequeue TrackerCell")
            return UICollectionViewCell()
        }

        guard let tracker = trackerDataProvider.tracker(at: indexPath) else {
            return UICollectionViewCell()
        }

        let completedDays = (try? trackerRecordStore.countRecords(for: tracker.id)) ?? 0
        let isCompletedToday = (try? trackerRecordStore.isRecordExist(for: tracker.id, on: currentDate)) ?? false

        cell.configure(
            title: tracker.name,
            emoji: tracker.emoji,
            days: completedDays,
            color: tracker.color,
            completed: isCompletedToday,
            isPinned: tracker.isPinned
        )
        cell.delegate = self
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                  ofKind: kind,
                  withReuseIdentifier: Constants.headerIdentifier,
                  for: indexPath
              ) as? HeaderView else {
            return UICollectionReusableView()
        }

        let title = trackerDataProvider.titleForSection(indexPath.section) ?? ""
        header.configure(with: title)
        return header
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let tracker = trackerDataProvider.tracker(at: indexPath) else { return nil }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let pinActionTitle = tracker.isPinned ? "Открепить" : "Закрепить"
            let pinAction = UIAction(title: pinActionTitle) { [weak self] _ in
                guard let self = self else { return }
                if tracker.isPinned {
                    self.unpinTracker(tracker)
                } else {
                    self.pinTracker(tracker)
                }
            }
            
            let editAction = UIAction(title: "Редактировать") { [weak self] _ in
                guard let self = self else { return }
                self.editTracker(tracker)
            }
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                guard let self = self else { return }
                self.deleteTracker(tracker)
            }
            
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: Constants.Layout.headerHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: Constants.Layout.sectionTopInset, left: 0, bottom: Constants.Layout.sectionBottomInset, right: 0)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let spacing: CGFloat = Constants.Layout.collectionSpacing
        let availableWidth = collectionView.bounds.width - spacing
        let itemWidth = availableWidth / 2
        
        let itemHeight: CGFloat = Constants.Layout.cellHeight
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
}

// MARK: - TrackerTypeViewControllerDelegate

extension HomeViewController: TrackerTypeViewControllerDelegate {
    func trackerTypeViewController(_ viewController: TrackerTypeViewController, didSelect type: TrackerType) {
        let createViewController = CreateTrackerViewController(type: type, trackerStore: trackerStore, trackerRecordStore: trackerRecordStore)
        viewController.navigationController?.pushViewController(createViewController, animated: true)
    }
}

// MARK: - TrackerCellDelegate

extension HomeViewController: TrackerCellDelegate {
    func trackerCellDidTapButton(_ cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        let calendar = Calendar.current
        if calendar.compare(currentDate, to: Date(), toGranularity: .day) == .orderedDescending {
            return
        }

        guard let tracker = trackerDataProvider.tracker(at: indexPath) else {
            print("Tracker not found at \(indexPath)")
            return
        }

        do {
            let isCompletedToday = try trackerRecordStore.isRecordExist(for: tracker.id, on: currentDate)

            if isCompletedToday {
                try trackerRecordStore.removeRecord(for: tracker.id, on: currentDate)
            } else {
                try trackerRecordStore.addRecord(for: tracker.id, on: currentDate)
            }

            let completedDays = try trackerRecordStore.countRecords(for: tracker.id)

            cell.configure(
                title: tracker.name,
                emoji: tracker.emoji,
                days: completedDays,
                color: tracker.color,
                completed: !isCompletedToday
            )
        } catch {
            print("Ошибка работы с TrackerRecordStore: \(error)")
        }
    }
}

// MARK: - TrackerDataProviderDelegate

extension HomeViewController: TrackerDataProviderDelegate {
    func didChangeContent() {
        collectionView.reloadData()
        updateUI()
    }
}

// MARK: - UISearchResultsUpdating

extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        searchText = text
        performSearch()
    }
}

// MARK: - FilterViewControllerDelegate

extension HomeViewController: FilterViewControllerDelegate {
    func didSelectFilter(_ filter: TrackerFilter) {
        selectedFilter = filter
        updateFilter()
        updateUI()
    }
}

// MARK: - Constants

extension HomeViewController {
    private enum Constants {
        static let title = "Трекеры"
        static let addButtonIcon = "PlusIcon"
        static let stubImage = "HomeViewStubImage"
        static let stubMessage = "Что будем отслеживать?"
        static let stubTitleFontSize: CGFloat = 12
        static let searchPlaceholder = "Поиск"
        static let cellIdentifier = "TrackerCell"
        static let headerIdentifier = "HeaderView"
        
        enum Layout {
            static let stubSpacing: CGFloat = 8
            static let stubImageWidth: CGFloat = 80
            static let datePickerWidth: CGFloat = 120
            static let collectionInset: CGFloat = 16
            static let collectionSpacing: CGFloat = 9
            static let headerHeight: CGFloat = 18
            static let sectionTopInset: CGFloat = 16
            static let sectionBottomInset: CGFloat = 16
            static let collectionTopInset: CGFloat = 8
            static let cellHeight: CGFloat = 148
            static let searchDebounceDelay: Double = 0.3
        }
    }
}
