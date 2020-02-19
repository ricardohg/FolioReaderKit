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
    
    fileprivate var insetBounds: CGRect {
        return bounds.insetBy(dx: 5, dy: 5)
    }
    
    var path: UIBezierPath {
        let path = PathFactory(viewRect: originalFrame()).createPath(for: type)
        path.transformAndCenter(transform: self.transform)
        return path
    }
    
    private(set) var lineWidth: CGFloat
    private(set) var fillColor: UIColor
    private(set) var shapeBorderColor: UIColor
    private var shapeLayer: CAShapeLayer!
    private var `type`: ShapeViewModel.ShapeType!   
    
    // MARK: - Life Cycle
    
    init(center: CGPoint, size: CGSize = CGSize(width: 100, height: 100), viewModel: ShapeViewModel) {
        let frame = CGRect(origin: .zero, size: size)
        
        self.lineWidth = viewModel.borderWidth
        self.fillColor = viewModel.fillColor
        self.shapeBorderColor = viewModel.borderColor
        self.type = viewModel.type
        super.init(frame: frame)
        backgroundColor = .clear
        self.center = center
        setupShapeLayer()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let path = PathFactory(viewRect: bounds).createPath(for: type)
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = fillColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.strokeColor = shapeBorderColor.cgColor
    }       
    
    // MARK: - Methods
    
    func change(lineWidth: CGFloat, fillColor: UIColor, shapeBorderColor: UIColor) {
        self.lineWidth = lineWidth
        self.fillColor = fillColor
        self.shapeBorderColor = shapeBorderColor
        setNeedsDisplay()
    }
    
    private func setupShapeLayer() {
        shapeLayer = CAShapeLayer()
        shapeLayer.frame = bounds
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
