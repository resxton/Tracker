import UIKit
import SnapKit

final class CreateTrackerViewController: UIViewController {
    
    // MARK: - Visual Components
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var buttonsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = .ypGrey
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.isScrollEnabled = false
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorStyle = .singleLine
        return tableView
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.text = "Test"
        textField.backgroundColor = .ypBackground
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.smartDashesType = .no
        textField.smartQuotesType = .no
        textField.smartInsertDeleteType = .no
        return textField
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collection.register(
            HeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HeaderView"
        )
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .clear
        collection.allowsMultipleSelection = false
        collection.isScrollEnabled = false
        return collection
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        collection.register(
            HeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HeaderView"
        )
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .clear
        collection.allowsMultipleSelection = false
        collection.isScrollEnabled = false
        return collection
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypWhite
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGrey
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Private Properties
    
    weak var delegate: CreateTrackerViewControllerDelegate?
    private let trackerType: TrackerType
    private var schedule: Schedule = []
    private var selectedEmoji: String?
    private var selectedColor: NamedColor?
    
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                         "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                         "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    private let colors: [NamedColor] = [
        NamedColor(name: "ColorSelection1", color: .colorSelection1),
        NamedColor(name: "ColorSelection2", color: .colorSelection2),
        NamedColor(name: "ColorSelection3", color: .colorSelection3),
        NamedColor(name: "ColorSelection4", color: .colorSelection4),
        NamedColor(name: "ColorSelection5", color: .colorSelection5),
        NamedColor(name: "ColorSelection6", color: .colorSelection6),
        NamedColor(name: "ColorSelection7", color: .colorSelection7),
        NamedColor(name: "ColorSelection8", color: .colorSelection8),
        NamedColor(name: "ColorSelection9", color: .colorSelection9),
        NamedColor(name: "ColorSelection10", color: .colorSelection10),
        NamedColor(name: "ColorSelection11", color: .colorSelection11),
        NamedColor(name: "ColorSelection12", color: .colorSelection12),
        NamedColor(name: "ColorSelection13", color: .colorSelection13),
        NamedColor(name: "ColorSelection14", color: .colorSelection14),
        NamedColor(name: "ColorSelection15", color: .colorSelection15),
        NamedColor(name: "ColorSelection16", color: .colorSelection16),
        NamedColor(name: "ColorSelection17", color: .colorSelection17),
        NamedColor(name: "ColorSelection18", color: .colorSelection18)
    ]
    
    // MARK: - Initializers
    
    init(type: TrackerType) {
        self.trackerType = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFieldDelegate()
        setupNavigationBar()
        buttonsTableView.delegate = self
        buttonsTableView.dataSource = self
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        navigationItem.title = trackerType.createTitle
        navigationItem.hidesBackButton = true
        
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
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        view.addSubview(buttonsStack)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(nameTextField)
        contentView.addSubview(buttonsTableView)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorCollectionView)
        
        buttonsStack.addArrangedSubview(cancelButton)
        buttonsStack.addArrangedSubview(createButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(buttonsStack.snp.top).offset(-16)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(75)
        }
        
        buttonsTableView.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(trackerType == .habit ? 150 : 75)
        }
        
        emojiCollectionView.snp.makeConstraints { make in
            make.top.equalTo(buttonsTableView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(204)
        }
        
        colorCollectionView.snp.makeConstraints { make in
            make.top.equalTo(emojiCollectionView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(204)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        buttonsStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(60)
        }
    }
    
    private func setupTextFieldDelegate() {
        nameTextField.delegate = self
    }
    
    private func updateCreateButtonState() {
        let isEnabled = !nameTextField.text!.isEmpty &&
                       selectedEmoji != nil &&
                       selectedColor != nil &&
                       (trackerType == .irregularEvent || !schedule.isEmpty)
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .ypBlack : .ypGrey
    }
    
    @objc private func categoryButtonTapped() {
        // TODO: Добавить экран выбора категории
    }
    
    @objc private func scheduleButtonTapped() {
        let scheduleViewController = ScheduleViewController(selectedSchedule: schedule)
        scheduleViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: scheduleViewController)
        present(navigationController, animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let name = nameTextField.text,
              let emoji = selectedEmoji,
              let selectedColor,
              !name.isEmpty else { return }
        
        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: selectedColor.name,
            emoji: emoji,
            schedule: trackerType == .habit ? schedule : .everyDay
        )

        delegate?.createTrackerViewController(self, didCreate: tracker)
        dismiss(animated: true)
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource

extension CreateTrackerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == emojiCollectionView ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "EmojiCell",
                for: indexPath
            ) as? EmojiCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: emojis[indexPath.item])
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ColorCell",
                for: indexPath
            ) as? ColorCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: colors[indexPath.item].color)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.item]
        } else {
            selectedColor = colors[indexPath.item]
        }
        updateCreateButtonState()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "HeaderView",
            for: indexPath
        ) as? HeaderView else {
            return UICollectionReusableView()
        }
        
        let title = collectionView == emojiCollectionView ? "Emoji" : "Цвет"
        header.configure(with: title)
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout {
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
        return UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
    }
}

// MARK: - UITextFieldDelegate

extension CreateTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateCreateButtonState()
    }
}

// MARK: - ScheduleViewControllerDelegate

extension CreateTrackerViewController: ScheduleViewControllerDelegate {
    func scheduleViewController(_ viewController: ScheduleViewController, didSelect schedule: Schedule) {
        self.schedule = schedule
        updateCreateButtonState()
        buttonsTableView.reloadData()
    }
    
    private func formatSchedule(_ schedule: Schedule) -> String? {
        if schedule.isEmpty {
            return nil
        }
        
        if schedule == .everyDay {
            return "Каждый день"
        }
        
        if schedule == [.monday, .tuesday, .wednesday, .thursday, .friday] {
            return "Будние дни"
        }
        
        if schedule == [.saturday, .sunday] {
            return "Выходные дни"
        }
        
        let days: [(Schedule, String)] = [
            (.monday, "Пн"),
            (.tuesday, "Вт"),
            (.wednesday, "Ср"),
            (.thursday, "Чт"),
            (.friday, "Пт"),
            (.saturday, "Сб"),
            (.sunday, "Вс")
        ]
        
        let selectedDays = days.filter { schedule.contains($0.0) }
            .map { $0.1 }
            .joined(separator: ", ")
        
        return selectedDays
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension CreateTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        trackerType == .habit ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ButtonsTableViewCell")
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = "Новая категория"
            cell.accessoryType = .disclosureIndicator
        } else if trackerType == .habit {
            cell.textLabel?.text = "Расписание"
            cell.detailTextLabel?.text = formatSchedule(schedule)
            cell.accessoryType = .disclosureIndicator
        }
        
        cell.textLabel?.textColor = .ypBlack
        cell.detailTextLabel?.textColor = .ypGrey
        cell.backgroundColor = .ypBackground
        cell.clipsToBounds = true
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            categoryButtonTapped()
        } else if trackerType == .habit {
            scheduleButtonTapped()
        }
    }
}
