//
//  ShapeView.swift
//  FolioReaderKit
//
//  Created by Santiago Carmona on 31/10/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import UIKit

class ShapeView: UIView {
    
    // MARK: - Vars & Constants
    
    var path: UIBezierPath {
        pathFactory.viewRect = superview?.frame ?? frame
        shapeLayer.path = pathFactory.createPath(for: type).cgPath
        return UIBezierPath(cgPath: shapeLayer.path!)
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
        initGestureRecognizers()
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
    
    func initGestureRecognizers() {
//        let panGR = UIPanGestureRecognizer(target: self, action: #selector(didPan))
//        addGestureRecognizer(panGR)
//        
//        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(didPinch))
//        addGestureRecognizer(pinchGR)
//        
//        let rotationGR = UIRotationGestureRecognizer(target: self, action: #selector(didRotate))
//        addGestureRecognizer(rotationGR)
    }
    
    func change(lineWidth: CGFloat, fillColor: UIColor, shapeBorderColor: UIColor) {
        self.lineWidth = lineWidth
        self.fillColor = fillColor
        self.shapeBorderColor = shapeBorderColor
        setNeedsDisplay()
    }
    
    @objc func didPan(sender: UIPanGestureRecognizer) {
        var translation = sender.translation(in: self)
        translation = translation.applying(self.transform)
        
        self.center.x += translation.x
        self.center.y += translation.y
//        shapePath.apply((CGAffineTransform(translationX: translation.x, y: translation.y)))
        
        sender.setTranslation(CGPoint.zero, in: self)
    }
    
    @objc func didPinch(sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        self.transform = self.transform.scaledBy(x: scale, y: scale)
//        shapePath.transformAndCenter(transform: CGAffineTransform(scaleX: scale, y: scale))
        setNeedsDisplay()
        sender.scale = 1.0
    }
    
    @objc func didRotate(sender: UIRotationGestureRecognizer) {
        self.superview!.bringSubviewToFront(self)
        let rotation = sender.rotation
        self.transform = self.transform.rotated(by: rotation)
//        shapePath.transformAndCenter(transform: CGAffineTransform(rotationAngle: rotation))
        
        sender.rotation = 0.0
    }

    
    private func setupShapePath(_ path: CGPath) {
        shapeLayer = CAShapeLayer()
        shapeLayer.frame = bounds
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)
    }
    
    func transformFromRect(from source: CGRect, toRect destination: CGRect) -> CATransform3D {
        let a = CATransform3DMakeTranslation(destination.midX - source.midX, destination.midY - source.midY, 0)
        let b = CATransform3DMakeScale(destination.width / source.width, destination.height / source.height, 1)
        return CATransform3DConcat(a, b)
    }
}

extension UIView {
    func transformAndCenter(transform: CGAffineTransform) {
        let beforeCenter = self.bounds.center
        self.transform = transform

        let afterCenter = self.bounds.center
        let diff = CGPoint(
            x: beforeCenter.x - afterCenter.x,
            y: beforeCenter.y - afterCenter.y
        )

        let translateTransform = CGAffineTransform(translationX: diff.x, y: diff.y)
        self.transform = translateTransform
    }
}
