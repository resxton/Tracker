import UIKit
import SnapKit

class StatsViewController: UIViewController {

    // MARK: - Visual Components
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.textColor = .ypBlack
        label.font = .boldSystemFont(ofSize: 34)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var statsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        return view
    }()
    
    private lazy var stubView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var stubImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "StatsViewStubImage")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var bestStreakCell = StatCellView()
    private lazy var perfectDaysCell = StatCellView()
    private lazy var completedTrackersCell = StatCellView()
    private lazy var averageRecordsCell = StatCellView()
    
    private lazy var bestStreakValue: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .boldSystemFont(ofSize: 34)
        return label
    }()
    
    private lazy var bestStreakSubtitle: UILabel = {
        let label = UILabel()
        label.text = "Лучший период"
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var perfectDaysValue: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .boldSystemFont(ofSize: 34)
        return label
    }()
    
    private lazy var perfectDaysSubtitle: UILabel = {
        let label = UILabel()
        label.text = "Идеальные дни"
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var completedTrackersValue: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .boldSystemFont(ofSize: 34)
        return label
    }()
    
    private lazy var completedTrackersSubtitle: UILabel = {
        let label = UILabel()
        label.text = "Завершенные трекеры"
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var averageRecordsValue: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .boldSystemFont(ofSize: 34)
        return label
    }()
    
    private lazy var averageRecordsSubtitle: UILabel = {
        let label = UILabel()
        label.text = "Среднее значение"
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    
    // MARK: - Private Properties
    
    private let trackerRecordStore: TrackerRecordStore
    private let trackerStore: TrackerStore
    private let trackerCategoryStore: TrackerCategoryStore
    
    // MARK: - Initializers
    
    init(trackerRecordStore: TrackerRecordStore, trackerStore: TrackerStore, trackerCategoryStore: TrackerCategoryStore) {
        self.trackerRecordStore = trackerRecordStore
        self.trackerStore = trackerStore
        self.trackerCategoryStore = trackerCategoryStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStats()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(statsContainer)
        view.addSubview(stubView)
        
        stubView.addSubview(stubImageView)
        stubView.addSubview(stubLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.leading.trailing.equalTo(view.layoutMarginsGuide)
        }
        
        statsContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.width.equalToSuperview().multipliedBy(0.9)
        }
        
        stubView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
        }
        
        stubImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        stubLabel.snp.makeConstraints { make in
            make.top.equalTo(stubImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        [bestStreakCell, perfectDaysCell, completedTrackersCell, averageRecordsCell].forEach { cell in
            statsContainer.addSubview(cell)
        }
        
        let cells = [(bestStreakCell, bestStreakValue, bestStreakSubtitle),
                     (perfectDaysCell, perfectDaysValue, perfectDaysSubtitle),
                     (completedTrackersCell, completedTrackersValue, completedTrackersSubtitle),
                     (averageRecordsCell, averageRecordsValue, averageRecordsSubtitle)]
        
        for (index, (cell, valueLabel, subtitleLabel)) in cells.enumerated() {
            cell.addSubview(valueLabel)
            cell.addSubview(subtitleLabel)
            
            cell.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(12)
                make.height.equalTo(90)
                make.top.equalTo(statsContainer.snp.top).offset(index * (90 + 12))
            }
            
            valueLabel.snp.makeConstraints { make in
                make.top.equalTo(cell.snp.top).offset(12)
                make.leading.equalTo(cell.snp.leading).offset(12)
                make.trailing.equalTo(cell.snp.trailing).offset(-12)
            }
            
            subtitleLabel.snp.makeConstraints { make in
                make.top.equalTo(valueLabel.snp.bottom).offset(12)
                make.leading.equalTo(cell.snp.leading).offset(12)
                make.bottom.equalTo(cell.snp.bottom).offset(-12)
                make.trailing.equalTo(cell.snp.trailing).offset(-12)
            }
        }
    }
    
    private func loadStats() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                let trackers = try self.trackerStore.fetchAll()
                
                DispatchQueue.main.async {
                    if trackers.isEmpty {
                        self.statsContainer.isHidden = true
                        self.stubView.isHidden = false
                    } else {
                        self.statsContainer.isHidden = false
                        self.stubView.isHidden = true
                        
                        let today = Date()
                        let records = try? self.trackerRecordStore.getTrackerIDsWithRecords(on: today)
                        
                        let bestStreak = self.calculateBestStreak(trackers: trackers)
                        let perfectDays = self.calculatePerfectDays(trackers: trackers)
                        let completedTrackers = records?.count ?? 0
                        let averageRecords = self.calculateAverageRecords(trackers: trackers)
                        
                        self.bestStreakValue.text = "\(bestStreak)"
                        self.perfectDaysValue.text = "\(perfectDays)"
                        self.completedTrackersValue.text = "\(completedTrackers)"
                        self.averageRecordsValue.text = "\(Int(averageRecords))"
                    }
                }
            } catch {
                print("Ошибка загрузки статистики: \(error)")
                DispatchQueue.main.async {
                    self.statsContainer.isHidden = true
                    self.stubView.isHidden = false
                }
            }
        }
    }
    
    private func calculateBestStreak(trackers: [Tracker]) -> Int {
        var maxStreak = 0
        let calendar = Calendar.current
        let today = Date()
        let lookbackPeriod = 30
        
        for tracker in trackers {
            var currentStreak = 0
            var maxTrackerStreak = 0
            var date = today
            
            for _ in 0..<lookbackPeriod {
                guard let records = try? trackerRecordStore.getTrackerIDsWithRecords(on: date) else {
                    currentStreak = 0
                    if let previousDate = calendar.date(byAdding: .day, value: -1, to: date) {
                        date = previousDate
                    } else {
                        break
                    }
                    continue
                }
                
                let weekday = calendar.component(.weekday, from: date)
                let scheduleDay = Schedule.fromWeekday(weekday)
                
                if records.contains(tracker.id) && tracker.schedule.contains(scheduleDay) {
                    currentStreak += 1
                    maxTrackerStreak = max(maxTrackerStreak, currentStreak)
                } else if tracker.schedule.contains(scheduleDay) {
                    currentStreak = 0
                }
                
                if let previousDate = calendar.date(byAdding: .day, value: -1, to: date) {
                    date = previousDate
                } else {
                    break
                }
            }
            
            maxStreak = max(maxStreak, maxTrackerStreak)
        }
        return maxStreak
    }
    
    private func calculatePerfectDays(trackers: [Tracker]) -> Int {
        let calendar = Calendar.current
        var perfectDaysCount = 0
        var date = Date()
        let lookbackPeriod = 30
        
        var recordsByDate = [Date: [UUID]]()
        var trackersByScheduleDay = [Schedule: [Tracker]]()
        
        for tracker in trackers {
            for day in tracker.schedule.selectedDays {
                var trackersForDay = trackersByScheduleDay[day] ?? []
                trackersForDay.append(tracker)
                trackersByScheduleDay[day] = trackersForDay
            }
        }
        
        for _ in 0..<lookbackPeriod {
            let normalizedDate = calendar.startOfDay(for: date)
            let weekday = calendar.component(.weekday, from: normalizedDate)
            let scheduleDay = Schedule.fromWeekday(weekday)
            
            let trackersForToday = trackersByScheduleDay[scheduleDay] ?? []
            
            if trackersForToday.isEmpty {
                if let previousDate = calendar.date(byAdding: .day, value: -1, to: date) {
                    date = previousDate
                } else {
                    break
                }
                continue
            }
            
            let dayRecords: [UUID]
            if let cachedRecords = recordsByDate[normalizedDate] {
                dayRecords = cachedRecords
            } else if let fetchedRecords = try? trackerRecordStore.getTrackerIDsWithRecords(on: normalizedDate) {
                recordsByDate[normalizedDate] = fetchedRecords
                dayRecords = fetchedRecords
            } else {
                dayRecords = []
            }
            
            let allTrackersCompleted = trackersForToday.allSatisfy { tracker in
                dayRecords.contains(tracker.id)
            }
            
            if allTrackersCompleted && !trackersForToday.isEmpty {
                perfectDaysCount += 1
            }
            
            if let previousDate = calendar.date(byAdding: .day, value: -1, to: date) {
                date = previousDate
            } else {
                break
            }
        }
        return perfectDaysCount
    }
    
    private func calculateAverageRecords(trackers: [Tracker]) -> Double {
        let totalTrackers = Double(trackers.count)
        if totalTrackers == 0 {
            return 0
        }
        
        var recordsCount = 0
        for tracker in trackers {
            if let count = try? trackerRecordStore.countRecords(for: tracker.id) {
                recordsCount += count
            }
        }
        
        return round(Double(recordsCount) / totalTrackers)
    }
}
