import UIKit

class FilterCell: UITableViewCell {
    
    // MARK: - Visual Components
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .ypBlack
        return label
    }()

    private lazy var checkmarkView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .blue
        imageView.isHidden = true
        return imageView
    }()
    
    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configure(with title: String, isSelected: Bool) {
        titleLabel.text = title
        checkmarkView.isHidden = !isSelected
    }
    
    // MARK: - Private Methods

    private func setupUI() {
        contentView.backgroundColor = .ypBackground
        contentView.clipsToBounds = true

        contentView.addSubview(titleLabel)
        contentView.addSubview(checkmarkView)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        checkmarkView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
}
