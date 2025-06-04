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
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let inset: CGFloat = 16
        let spacing: CGFloat = 9
        let availableWidth = UIScreen.main.bounds.width - (inset * 2) - spacing
        let itemWidth = availableWidth / 2
        
        layout.itemSize = CGSize(width: itemWidth, height: 148) // Высота будет динамически настраиваться в делегате
        layout.minimumLineSpacing = 0 // Вертикальный отступ между ячейками
        layout.minimumInteritemSpacing = spacing // Горизонтальный отступ между ячейками
        layout.sectionInset = UIEdgeInsets(top: 8, left: inset, bottom: 16, right: inset)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(
            HeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HeaderView"
        )
        
        return collectionView
    }()
    
    // MARK: - Private Properties

    private var categories: [TrackerCategory] = []
    private var currentDate = Date()
    private var completedTrackers: [TrackerRecord] = []
    private var visibleCategories: [TrackerCategory] = []
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItems()
        setupUI()
        setupConstraints()
        setupTestData()
        updateVisibleCategories()
        updateStubViewVisibility()
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
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        datePicker.date = currentDate
        
        datePicker.snp.makeConstraints { make in
            make.width.equalTo(Constants.Layout.datePickerWidth)
        }
        
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
    }
    
    private func setupUI() {
        view.addSubview(stubView)
        view.addSubview(collectionView)
        stubView.isHidden = true
    }
    
    private func setupConstraints() {
        stubView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.layoutMarginsGuide)
            make.centerY.equalTo(view.layoutMarginsGuide.snp.centerY)
        }
        
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.layoutMarginsGuide)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
        }
    }
    
    private func updateVisibleCategories() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        let filterSchedule: Schedule
        
        // Преобразуем системный номер дня недели (1-7, где 1 - воскресенье) 
        // в наш формат Schedule
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
        
        visibleCategories = categories.compactMap { category in
            let visibleTrackers = category.trackers.filter { tracker in
                tracker.schedule.contains(filterSchedule)
            }
            
            if visibleTrackers.isEmpty {
                return nil
            }
            
            return TrackerCategory(title: category.title, trackers: visibleTrackers)
        }
        
        collectionView.reloadData()
    }
    
    private func updateStubViewVisibility() {
        let hasTrackers = visibleCategories.contains { !$0.trackers.isEmpty }
        stubView.isHidden = hasTrackers
        collectionView.isHidden = !hasTrackers
    }
    
    private func setupTestData() {
        let habits = TrackerCategory(
            title: "Привычки",
            trackers: [
                Tracker(
                    id: UUID(),
                    name: "Медитация",
                    color: "colorSelection1",
                    emoji: "🧘‍♂️",
                    schedule: .everyDay
                ),
                Tracker(
                    id: UUID(),
                    name: "Пить воду",
                    color: "colorSelection2",
                    emoji: "💧",
                    schedule: [.monday, .wednesday, .friday]
                ),
                Tracker(
                    id: UUID(),
                    name: "Йога",
                    color: "colorSelection3",
                    emoji: "🧘‍♀️",
                    schedule: [.tuesday, .thursday]
                )
            ]
        )
        
        let irregularEvents = TrackerCategory(
            title: "Нерегулярные события",
            trackers: [
                Tracker(
                    id: UUID(),
                    name: "Прочитать книгу",
                    color: "colorSelection4",
                    emoji: "📚",
                    schedule: .everyDay
                ),
                Tracker(
                    id: UUID(),
                    name: "Сходить в кино",
                    color: "colorSelection5",
                    emoji: "🎬",
                    schedule: .everyDay
                )
            ]
        )
        
        categories = [habits, irregularEvents]
        
        // Добавим несколько выполненных трекеров для примера
        if let firstTracker = categories.first?.trackers.first {
            completedTrackers = [
                TrackerRecord(id: firstTracker.id, date: Date()),
                TrackerRecord(id: firstTracker.id, date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())
            ]
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "TrackerCell",
            for: indexPath
        ) as? TrackerCell else {
            assertionFailure("Failed to dequeue TrackerCell")
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let completedDays = completedTrackers.filter { $0.id == tracker.id }.count
        let isCompletedToday = completedTrackers.contains { 
            $0.id == tracker.id && 
            Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }
        
        cell.configure(
            title: tracker.name,
            emoji: tracker.emoji,
            days: completedDays,
            color: UIColor(named: tracker.color) ?? .colorSelection1,
            completed: isCompletedToday
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
                withReuseIdentifier: "HeaderView",
                for: indexPath
              ) as? HeaderView else {
            return UICollectionReusableView()
        }
        
        let category = visibleCategories[indexPath.section]
        header.configure(with: category.title)
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let inset: CGFloat = 16
        let spacing: CGFloat = 9
        let availableWidth = collectionView.bounds.width - (inset * 2) - spacing
        let itemWidth = availableWidth / 2
        
        // Высота карточки + отступ под кнопкой
        let itemHeight: CGFloat = 90 + 58 // 90 для карточки и 42 для области с кнопкой (включая отступы)
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
}

// MARK: - TrackerTypeViewControllerDelegate

extension HomeViewController: TrackerTypeViewControllerDelegate {
    func trackerTypeViewController(_ viewController: TrackerTypeViewController, didSelect type: TrackerType) {
        let createViewController = CreateTrackerViewController(type: type)
        createViewController.delegate = self
        viewController.navigationController?.pushViewController(createViewController, animated: true)
    }
}

// MARK: - CreateTrackerViewControllerDelegate

extension HomeViewController: CreateTrackerViewControllerDelegate {
    func createTrackerViewController(_ viewController: CreateTrackerViewController, didCreate tracker: Tracker) {
        // Создаем новую категорию или добавляем в существующую
        let category: TrackerCategory
        if let existingCategory = categories.first {
            let updatedTrackers = existingCategory.trackers + [tracker]
            category = TrackerCategory(title: existingCategory.title, trackers: updatedTrackers)
            categories[0] = category
        } else {
            category = TrackerCategory(title: "Новая категория", trackers: [tracker])
            categories = [category]
        }
        
        updateVisibleCategories()
        updateStubViewVisibility()
    }
}

// MARK: - TrackerCellDelegate

extension HomeViewController: TrackerCellDelegate {
    func trackerCellDidTapButton(_ cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        // Проверяем, не является ли выбранная дата будущей
        let calendar = Calendar.current
        if calendar.compare(currentDate, to: Date(), toGranularity: .day) == .orderedDescending {
            return
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        // Проверяем, был ли трекер уже выполнен сегодня
        let isCompletedToday = completedTrackers.contains { 
            $0.id == tracker.id && 
            Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }
        
        if isCompletedToday {
            // Удаляем запись о выполнении
            completedTrackers.removeAll { 
                $0.id == tracker.id && 
                Calendar.current.isDate($0.date, inSameDayAs: currentDate)
            }
        } else {
            // Добавляем новую запись о выполнении
            let record = TrackerRecord(id: tracker.id, date: currentDate)
            completedTrackers.append(record)
        }
        
        // Обновляем ячейку
        let completedDays = completedTrackers.filter { $0.id == tracker.id }.count
        cell.configure(
            title: tracker.name,
            emoji: tracker.emoji,
            days: completedDays,
            color: UIColor(named: tracker.color) ?? .colorSelection1,
            completed: !isCompletedToday
        )
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
