import UIKit
import SnapKit

final class ScheduleViewController: UIViewController {
    
    // MARK: - Visual Components
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "WeekDayCell")
        table.delegate = self
        table.dataSource = self
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.separatorColor = .ypGrey
        table.layer.cornerRadius = 16
        table.backgroundColor = .ypBackground
        return table
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    
    weak var delegate: ScheduleViewControllerDelegate?
    private var selectedDays: Schedule
    
    private let weekDays: [(title: String, schedule: Schedule)] = [
        ("Понедельник", .monday),
        ("Вторник", .tuesday),
        ("Среда", .wednesday),
        ("Четверг", .thursday),
        ("Пятница", .friday),
        ("Суббота", .saturday),
        ("Воскресенье", .sunday)
    ]
    
    // MARK: - Initializers
    
    init(selectedSchedule: Schedule) {
        self.selectedDays = selectedSchedule
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        navigationItem.title = "Расписание"
        
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
        
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(CGFloat(weekDays.count) * 75)
        }
        
        doneButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(60)
        }
    }
    
    @objc private func doneButtonTapped() {
        delegate?.scheduleViewController(self, didSelect: selectedDays)
        dismiss(animated: true)
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let day = weekDays[sender.tag].schedule
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeekDayCell", for: indexPath)
        let weekDay = weekDays[indexPath.row]
        
        cell.textLabel?.text = weekDay.title
        cell.backgroundColor = .ypBackground
        cell.selectionStyle = .none
        
        let switchView = UISwitch()
        switchView.tag = indexPath.row
        switchView.isOn = selectedDays.contains(weekDay.schedule)
        switchView.onTintColor = .ypBlue
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        cell.accessoryView = switchView
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
} 
