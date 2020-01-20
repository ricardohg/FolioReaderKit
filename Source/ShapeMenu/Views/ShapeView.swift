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
    
    private(set) var lineWidth: CGFloat
    private(set) var fillColor: UIColor
    private(set) var shapeBorderColor: UIColor
    private(set) var path: UIBezierPath!
    private var shapeLayer: CAShapeLayer!
    private var didDrawForFirstTime: Bool = false
    private var `type`: ShapeViewModel.ShapeType!
    private var lineWidthScaleFactor: CGFloat {
        return frame.size.height / bounds.size.height
    }
    
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
        path = PathFactory(viewRect: insetBounds).createPath(for: viewModel.type)
        setupShapePath()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        shapeLayer.fillColor = fillColor.cgColor
        shapeLayer.lineWidth = lineWidth / lineWidthScaleFactor
        shapeLayer.strokeColor = shapeBorderColor.cgColor
        
        if !didDrawForFirstTime {
            didDrawForFirstTime.toggle()
            path.apply((CGAffineTransform(translationX: frame.origin.x, y: frame.origin.y)))
        }
    }
    
    // MARK: - Methods
    
    func change(lineWidth: CGFloat, fillColor: UIColor, shapeBorderColor: UIColor) {
        self.lineWidth = lineWidth
        self.fillColor = fillColor
        self.shapeBorderColor = shapeBorderColor
        setNeedsDisplay()
    }
    
    @objc override func handleMove(gesture:UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview!)
        
        var center = self.center
        center.x += translation.x
        center.y += translation.y
        self.center = center
        path.apply((CGAffineTransform(translationX: translation.x, y: translation.y)))
        gesture.setTranslation(CGPoint.zero, in: self.superview!)
        updateDragHandles()
    }
    
    @objc override func handleRotate(gesture:UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            previousLocation = rotateHandle.center
            self.drawRotateLine(fromPoint: CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2), toPoint:CGPoint(x: self.bounds.size.width + diameter, y: self.bounds.size.height/2))
        case .ended:
            self.rotateLine.opacity = 0.0
        default:()
        }
        let location = gesture.location(in: self.superview!)
        let angle = angleBetweenPoints(startPoint: previousLocation, endPoint: location)
        self.transform = self.transform.rotated(by: angle)
        path.transformAndCenter(transform: CGAffineTransform(rotationAngle: angle))
        previousLocation = location
        self.updateDragHandles()
    }
    
    @objc override func handlePan(gesture:UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let oldBounds = bounds.size
        switch gesture.view! {
        case topLeft:
            if gesture.state == .began {
                self.setAnchorPoint(anchorPoint: CGPoint(x: 1, y: 1))
            }
            self.bounds.size.width -= translation.x
            self.bounds.size.height -= translation.y
        case topRight:
            if gesture.state == .began {
                self.setAnchorPoint(anchorPoint: CGPoint(x: 0, y: 1))
            }
            self.bounds.size.width += translation.x
            self.bounds.size.height -= translation.y
        case bottomLeft:
            if gesture.state == .began {
                self.setAnchorPoint(anchorPoint: CGPoint(x: 1, y: 0))
            }
            self.bounds.size.width -= translation.x
            self.bounds.size.height += translation.y
        case bottomRight:
            if gesture.state == .began {
                self.setAnchorPoint(anchorPoint: CGPoint.zero)
            }
            self.bounds.size.width += translation.x
            self.bounds.size.height += translation.y
        default:()
        }
                    
        gesture.setTranslation(CGPoint.zero, in: self)
        updateDragHandles()
        path.transformAndCenter(transform: CGAffineTransform(scaleX: bounds.width / oldBounds.width, y: bounds.height / oldBounds.height))
        path.apply(CGAffineTransform(translationX: frame.center.x - path.bounds.center.x, y: frame.center.y - path.bounds.center.y))
        shapeLayer.transform = CATransform3DScale(shapeLayer.transform, bounds.width / oldBounds.width, bounds.height / oldBounds.height, 1.0)
        shapeLayer.frame = bounds
        
        if gesture.state == .ended {
            self.setAnchorPoint(anchorPoint: CGPoint(x: 0.5, y: 0.5))
        }
    }
    
    private func setupShapePath() {
        shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
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
