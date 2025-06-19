import UIKit
import SnapKit

final class StatCellView: UIView {
    
    // MARK: - Private Properties
    
    private let gradientLayer = CAGradientLayer()
    private let shapeLayer = CAShapeLayer()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        
        let outerPath = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
        let innerPath = UIBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1), cornerRadius: 15).cgPath
        
        let path = CGMutablePath()
        path.addPath(outerPath)
        path.addPath(innerPath)
        
        shapeLayer.path = path
    }
    
    // MARK: - Private Methods
    
    private func setup() {
        backgroundColor = .ypWhite
        layer.cornerRadius = 16
        
        gradientLayer.cornerRadius = 16
        
        let leftColor = UIColor.colorSelection1.cgColor
        let centerColor = UIColor.colorSelection9.cgColor
        let rightColor = UIColor.colorSelection3.cgColor
        
        gradientLayer.colors = [leftColor, centerColor, rightColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.type = .axial
        
        shapeLayer.fillRule = .evenOdd
        
        layer.addSublayer(gradientLayer)
        gradientLayer.mask = shapeLayer
    }
}
