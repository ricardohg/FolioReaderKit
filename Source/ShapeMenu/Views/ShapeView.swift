//
//  ShapeView.swift
//  FolioReaderKit
//
//  Created by Santiago Carmona on 31/10/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import UIKit

class ShapeView: ResizableView {
    
    // MARK: - Vars & Constants
    
    var path: UIBezierPath {
        let radians: Double = atan2( Double(transform.b), Double(transform.a))
        let degrees: Double = radians * (180 / Double.pi )
        self.transform = .identity
        pathFactory.viewRect = frame
        shapeLayer.path = pathFactory.createPath(for: type).cgPath
        let path = UIBezierPath(cgPath: shapeLayer.path!)
        path.transformAndCenter(transform: (CGAffineTransform(rotationAngle: CGFloat(degrees))))
        return path
    }
    
    fileprivate var insetBounds: CGRect {
        return bounds.insetBy(dx: 5, dy: 5)
    }
    
    private(set) var lineWidth: CGFloat
    private(set) var fillColor: UIColor
    private(set) var shapeBorderColor: UIColor
    private(set) var shapeLayer: CAShapeLayer!
    private var didDrawForFirstTime: Bool = false
    private var lineWidthScaleFactor: CGFloat {
        return frame.size.height / bounds.size.height
    }
    private var pathFactory: PathFactory!
    private var `type`: ShapeViewModel.ShapeType
    
    // MARK: - Life Cycle
    
    init(origin: CGPoint, size: CGSize = CGSize(width: 100, height: 100), viewModel: ShapeViewModel) {
        let frame = CGRect(origin: .zero, size: size)
        self.lineWidth = viewModel.borderWidth
        self.fillColor = viewModel.fillColor
        self.shapeBorderColor = viewModel.borderColor
        self.type = viewModel.type
        super.init(frame: frame)
        backgroundColor = .clear
        center = origin
        pathFactory = PathFactory(viewRect: insetBounds)
        setupShapePath(pathFactory.createPath(for: viewModel.type).cgPath)        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        pathFactory.viewRect = insetBounds
        shapeLayer.path = pathFactory.createPath(for: type).cgPath
        shapeLayer.fillColor = fillColor.cgColor
        shapeLayer.lineWidth = lineWidth / lineWidthScaleFactor
        shapeLayer.strokeColor = shapeBorderColor.cgColor
    }
    
    // MARK: - Methods
    
    func change(lineWidth: CGFloat, fillColor: UIColor, shapeBorderColor: UIColor) {
        self.lineWidth = lineWidth
        self.fillColor = fillColor
        self.shapeBorderColor = shapeBorderColor
        setNeedsDisplay()
    }
    
    private func setupShapePath(_ path: CGPath) {
        shapeLayer = CAShapeLayer()
        shapeLayer.frame = bounds
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)
    }
}

private extension UIBezierPath {
    func transformAndCenter(transform: CGAffineTransform) {
        let beforeCenter = self.bounds.center
        self.apply(transform)

        let afterCenter = self.bounds.center
        let diff = CGPoint(
            x: beforeCenter.x - afterCenter.x,
            y: beforeCenter.y - afterCenter.y
        )

        let translateTransform = CGAffineTransform(translationX: diff.x, y: diff.y)
        self.apply(translateTransform)
    }
}
