import UIKit

final class EmojiCell: UICollectionViewCell {
    
    // MARK: - Visual Components
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Public Properties
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? .ypLightGray : .clear
            layer.cornerRadius = 16
        }
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configure(with emoji: String) {
        emojiLabel.text = emoji
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        contentView.addSubview(emojiLabel)
        
        emojiLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
} 
