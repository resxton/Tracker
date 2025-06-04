import UIKit
import SnapKit

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func createTrackerViewController(_ viewController: CreateTrackerViewController, didCreate tracker: Tracker)
}

final class CreateTrackerViewController: UIViewController {
    
    // MARK: - Visual Components
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
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
    
    private lazy var scheduleButton: UIButton = {
        let button = UIButton()
        button.setTitle("Расписание", for: .normal)
        button.setTitleColor(.ypBlack, for: .normal)
        button.backgroundColor = .ypBackground
        button.layer.cornerRadius = 16
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.backgroundColor = .white
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
        button.backgroundColor = .ypGrey
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Properties
    
    weak var delegate: CreateTrackerViewControllerDelegate?
    private let trackerType: TrackerType
    private var schedule: Schedule = []
    
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
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        navigationItem.title = trackerType.createTitle
        
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
        
        view.addSubview(nameTextField)
        view.addSubview(buttonsStack)
        
        if trackerType == .habit {
            view.addSubview(scheduleButton)
            
            scheduleButton.snp.makeConstraints { make in
                make.top.equalTo(nameTextField.snp.bottom).offset(24)
                make.leading.trailing.equalToSuperview().inset(16)
                make.height.equalTo(75)
            }
        }
        
        buttonsStack.addArrangedSubview(cancelButton)
        buttonsStack.addArrangedSubview(createButton)
        
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(75)
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
        let isEnabled = !nameTextField.text!.isEmpty && (trackerType == .irregularEvent || !schedule.isEmpty)
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .ypBlack : .ypGrey
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
        guard let name = nameTextField.text, !name.isEmpty else { return }
        
        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: "colorSelection1", // TODO: Добавить выбор цвета
            emoji: "😊", // TODO: Добавить выбор эмодзи
            schedule: trackerType == .habit ? schedule : .everyDay
        )
        
        delegate?.createTrackerViewController(self, didCreate: tracker)
        dismiss(animated: true)
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
        updateScheduleButtonTitle()
        updateCreateButtonState()
    }
    
    private func updateScheduleButtonTitle() {
        let daysString = formatSchedule(schedule)
        scheduleButton.setTitle("Расписание: \(daysString)", for: .normal)
    }
    
    private func formatSchedule(_ schedule: Schedule) -> String {
        if schedule.isEmpty {
            return "Не выбрано"
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
