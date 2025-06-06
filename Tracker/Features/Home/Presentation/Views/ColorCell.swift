import UIKit

final class ColorCell: UICollectionViewCell {
    
    // MARK: - Visual Components
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override Methods
    
    override var isSelected: Bool {
        didSet {
            layer.borderWidth = isSelected ? 3 : 0
            layer.borderColor = colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
            layer.cornerRadius = 8
        }
    }
    
    // MARK: - Public Methods
    
    func configure(with color: UIColor) {
        colorView.backgroundColor = color
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        contentView.addSubview(colorView)
        
        colorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(40)
        }
    }
} 