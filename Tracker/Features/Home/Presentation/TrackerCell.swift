import UIKit
import SnapKit

protocol TrackerCellDelegate: AnyObject {
    func trackerCellDidTapButton(_ cell: TrackerCell)
}

extension TrackerCell {
    private enum Constants {
        static let cardCornerRadius: CGFloat = 16
        static let emojiBackgroundCornerRadius: CGFloat = 14
        static let plusButtonCornerRadius: CGFloat = 17
        
        static let cardHeight: CGFloat = 90
        static let buttonSize: CGFloat = 34
        static let emojiBackgroundSize: CGFloat = 28
        
        static let defaultInset: CGFloat = 12
        static let titleBottomInset: CGFloat = 12
        static let buttonBottomInset: CGFloat = 16
        
        static let titleFontSize: CGFloat = 12
        static let emojiFontSize: CGFloat = 16
        static let daysLabelFontSize: CGFloat = 12
        
        static let emojiBackgroundAlpha: CGFloat = 0.3
        static let completedButtonAlpha: CGFloat = 0.3
    }
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
    
    // MARK: - Public Methods
    
    func configure(title: String, emoji: String, days: Int, color: String, completed: Bool = false) {
        titleLabel.text = title
        emojiLabel.text = emoji
        daysLabel.text = formatDaysCount(days)
        if let colorAsset = UIColor(named: color) {
            cardView.backgroundColor = colorAsset
            plusButton.backgroundColor = colorAsset
        } else {
            print("There is no color named \(color)")
        }
        isCompleted = completed
        updateButtonStyle()
    }

    // MARK: - Private Methods
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = Constants.cardCornerRadius
        contentView.clipsToBounds = true

        cardView.layer.cornerRadius = Constants.cardCornerRadius
        cardView.backgroundColor = UIColor.systemGreen
        contentView.addSubview(cardView)

        emojiBackgroundView.backgroundColor = .ypWhite.withAlphaComponent(
            Constants.emojiBackgroundAlpha
        )
        emojiBackgroundView.layer.cornerRadius = Constants.emojiBackgroundCornerRadius
        cardView.addSubview(emojiBackgroundView)

        emojiLabel.text = "💋"
        emojiLabel.numberOfLines = 1
        emojiLabel.adjustsFontSizeToFitWidth = false
        emojiLabel.minimumScaleFactor = 1
        emojiLabel.textAlignment = .center
        emojiLabel.font = .systemFont(ofSize: Constants.emojiFontSize, weight: .medium)
        emojiBackgroundView.addSubview(emojiLabel)

        titleLabel.text = "Поливать растения"
        titleLabel.font = UIFont.systemFont(ofSize: Constants.titleFontSize, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        cardView.addSubview(titleLabel)

        daysLabel.text = "1 день"
        daysLabel.font = UIFont.systemFont(ofSize: Constants.daysLabelFontSize, weight: .medium)
        daysLabel.textColor = .ypBlack
        contentView.addSubview(daysLabel)

        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        plusButton.tintColor = .white
        plusButton.backgroundColor = .systemGreen
        plusButton.layer.cornerRadius = Constants.plusButtonCornerRadius
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        contentView.addSubview(plusButton)
    }

    private func layoutUI() {
        cardView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(Constants.cardHeight)
        }

        emojiBackgroundView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(Constants.defaultInset)
            make.width.height.equalTo(Constants.emojiBackgroundSize)
        }

        emojiLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview().inset(Constants.titleBottomInset)
        }

        daysLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Constants.defaultInset)
            make.top.equalTo(cardView.snp.bottom).offset(Constants.defaultInset)
        }

        plusButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Constants.defaultInset)
            make.centerY.equalTo(daysLabel.snp.centerY)
            make.width.height.equalTo(Constants.buttonSize)
            make.bottom.equalToSuperview().inset(Constants.buttonBottomInset)
        }
    }
    
    private func updateButtonStyle() {
        plusButton.setImage(
            isCompleted ? UIImage(systemName: "checkmark")?.withTintColor(.white) : UIImage(resource: .plusIcon),
            for: .normal
        )
        plusButton.alpha = isCompleted ? Constants.completedButtonAlpha : 1.0
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
    
    @objc private func plusButtonTapped() {
        delegate?.trackerCellDidTapButton(self)
    }
}
