import UIKit
import SnapKit

protocol TrackerCellDelegate: AnyObject {
    func trackerCellDidTapButton(_ cell: TrackerCell)
}

final class TrackerCell: UICollectionViewCell {
    
    // MARK: - Visual Components

    private let cardView = UIView()
    private let emojiBackgroundView = UIView()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let daysLabel = UILabel()
    private let plusButton = UIButton()
    
    // MARK: - Properties
    
    weak var delegate: TrackerCellDelegate?
    private var isCompleted: Bool = false
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        layoutUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true

        // Card View
        cardView.layer.cornerRadius = 16
        cardView.backgroundColor = UIColor.systemGreen
        contentView.addSubview(cardView)

        // Emoji
        emojiBackgroundView.backgroundColor = .ypWhite.withAlphaComponent(0.3)
        emojiBackgroundView.layer.cornerRadius = 14
        cardView.addSubview(emojiBackgroundView)

        emojiLabel.text = "💋"
        emojiLabel.numberOfLines = 1
        emojiLabel.adjustsFontSizeToFitWidth = false
        emojiLabel.minimumScaleFactor = 1
        emojiLabel.textAlignment = .center
        emojiLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emojiBackgroundView.addSubview(emojiLabel)

        // Title
        titleLabel.text = "Поливать растения"
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        cardView.addSubview(titleLabel)

        // Days label
        daysLabel.text = "1 день"
        daysLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        daysLabel.textColor = .ypBlack
        contentView.addSubview(daysLabel)

        // Plus button
        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        plusButton.tintColor = .white
        plusButton.backgroundColor = .systemGreen
        plusButton.layer.cornerRadius = 17
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        contentView.addSubview(plusButton)
    }

    private func layoutUI() {
        cardView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(90)
        }

        emojiBackgroundView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(28)
        }

        emojiLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview().inset(12)
        }

        daysLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.equalTo(cardView.snp.bottom).offset(16)
        }

        plusButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalTo(daysLabel.snp.centerY)
            make.width.height.equalTo(34)
            make.bottom.equalToSuperview().inset(16)
        }
    }

    // MARK: - Configuration
    
    func configure(title: String, emoji: String, days: Int, color: UIColor, completed: Bool = false) {
        titleLabel.text = title
        emojiLabel.text = emoji
        daysLabel.text = formatDaysCount(days)
        cardView.backgroundColor = color
        plusButton.backgroundColor = color
        isCompleted = completed
        updateButtonStyle()
    }
    
    private func updateButtonStyle() {
        plusButton.setImage(
            isCompleted ? UIImage(systemName: "checkmark")?.withTintColor(.white) : UIImage(named: "PlusIcon"),
            for: .normal
        )
        plusButton.alpha = isCompleted ? 0.3 : 1.0
    }
    
    private func formatDaysCount(_ count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            return "\(count) дней"
        }
        
        switch lastDigit {
        case 1:
            return "\(count) день"
        case 2...4:
            return "\(count) дня"
        default:
            return "\(count) дней"
        }
    }
    
    // MARK: - Actions
    
    @objc private func plusButtonTapped() {
        delegate?.trackerCellDidTapButton(self)
    }
}
