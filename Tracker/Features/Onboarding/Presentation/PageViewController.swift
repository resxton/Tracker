import UIKit
import SnapKit

final class PageViewController: UIViewController {
    
    // MARK: - Visual Components
    
    private let backgroundImage: UIImageView
    private let label = UILabel()
    
    // MARK: - Initializers
    
    init(page: PageNumber, labelText: String) {
        let imageName = "Onboarding\(page == .first ? 1 : 2)"
        backgroundImage = UIImageView(image: UIImage(named: imageName) ?? UIImage())
        super.init(nibName: nil, bundle: nil)
        label.text = labelText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.addSubview(backgroundImage)
        view.addSubview(label)
        
        label.textColor = .black
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
    }
    
    private func setupConstraints() {
        backgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        label.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.layoutMarginsGuide).inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(432)
        }
    }
}

// MARK: - Types

extension PageViewController {
    enum PageNumber {
        case first
        case second
    }
}
