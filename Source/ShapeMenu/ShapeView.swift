//
//  ShapeView.swift
//  FolioReaderKit
//
//  Created by Santiago Carmona on 31/10/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import UIKit

class ShapeView: UIView {
    enum Gestures {
        case pan
        case pinch
        case rotate
    }
    
    // MARK: - Vars & Constants
    
    var path: UIBezierPath {
        return shapePath
    }
    
    fileprivate var insetBounds: CGRect {
        return bounds.insetBy(dx: 5, dy: 5)
    }
    
    private(set) var lineWidth: CGFloat
    private(set) var fillColor: UIColor
    private(set) var shapeBorderColor: UIColor
    private var shapePath: UIBezierPath!
    private var shapeLayer: CAShapeLayer!
    private var didDrawForFirstTime: Bool = false
    private var lineWidthScaleFactor: CGFloat {
        return frame.size.height / bounds.size.height
    }
    
    var gestures: [Gestures] {
        return [.pinch, .pan]
    }
    
    // MARK: - Life Cycle
    
    init(origin: CGPoint, size: CGSize, lineWidth: CGFloat, fillColor: UIColor, shapeBorderColor: UIColor) {
        let frame = CGRect(origin: .zero, size: size)
        self.lineWidth = lineWidth
        self.fillColor = fillColor
        self.shapeBorderColor = shapeBorderColor
        super.init(frame: frame)
        backgroundColor = .clear
        center = origin
        initGestureRecognizers(gestures)
        shapePath = createPath()
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
            shapePath.apply((CGAffineTransform(translationX: frame.origin.x, y: frame.origin.y)))
        }
    }
    
    // MARK: - Methods
    
    func createPath() -> UIBezierPath {
        return UIBezierPath()
    }
    
    func initGestureRecognizers(_ gestures: [Gestures]) {
        for gesture in gestures {
            switch gesture {
            case .pan:
                let panGR = UIPanGestureRecognizer(target: self, action: #selector(didPan))
                addGestureRecognizer(panGR)
            case .pinch:
                let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(didPinch))
                addGestureRecognizer(pinchGR)
            case .rotate:
                let rotationGR = UIRotationGestureRecognizer(target: self, action: #selector(didRotate))
                addGestureRecognizer(rotationGR)
            }
        }
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
        shapePath.apply((CGAffineTransform(translationX: translation.x, y: translation.y)))
        
        sender.setTranslation(CGPoint.zero, in: self)
    }
    
    @objc func didPinch(sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        self.transform = self.transform.scaledBy(x: scale, y: scale)
        shapePath.transformAndCenter(transform: CGAffineTransform(scaleX: scale, y: scale))
        setNeedsDisplay()
        sender.scale = 1.0
    }
    
    @objc func didRotate(sender: UIRotationGestureRecognizer) {        
        self.superview!.bringSubviewToFront(self)
        let rotation = sender.rotation
        self.transform = self.transform.rotated(by: rotation)
        shapePath.transformAndCenter(transform: CGAffineTransform(rotationAngle: rotation))
        
        sender.rotation = 0.0
    }

    
    private func setupShapePath() {
        shapeLayer = CAShapeLayer()
        shapeLayer.path = shapePath.cgPath
        layer.addSublayer(shapeLayer)
    }
}

extension UIBezierPath {
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

class Rectangle: ShapeView {
    override init(origin: CGPoint, size: CGSize = .init(width: 200, height: 100), lineWidth: CGFloat, fillColor: UIColor, shapeBorderColor: UIColor) {
        super.init(origin: origin, size: size, lineWidth: lineWidth, fillColor: fillColor, shapeBorderColor: shapeBorderColor)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func createPath() -> UIBezierPath {
        return UIBezierPath(rect: insetBounds)
    }
}

class Circle: ShapeView {
    override init(origin: CGPoint, size: CGSize = .init(width: 100, height: 100), lineWidth: CGFloat, fillColor: UIColor, shapeBorderColor: UIColor) {
        super.init(origin: origin, size: size, lineWidth: lineWidth, fillColor: fillColor, shapeBorderColor: shapeBorderColor)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func createPath() -> UIBezierPath {
        return UIBezierPath(ovalIn: insetBounds)
    }
}

class Triangle: ShapeView {
    override init(origin: CGPoint, size: CGSize = .init(width: 100, height: 100), lineWidth: CGFloat, fillColor: UIColor, shapeBorderColor: UIColor) {
        super.init(origin: origin, size: size, lineWidth: lineWidth, fillColor: fillColor, shapeBorderColor: shapeBorderColor)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func createPath() -> UIBezierPath {
        let rect = insetBounds
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.width / 2.0, y: rect.origin.y))
        path.addLine(to: CGPoint(x: rect.width,y: rect.height))
        path.addLine(to: CGPoint(x: rect.origin.x,y: rect.height))
        path.close()
        
        return path
    }
}

class Arrow: ShapeView {
    override var gestures: [ShapeView.Gestures] {
        return [.pinch, .pan, .rotate]
    }
    
    override init(origin: CGPoint, size: CGSize = .init(width: 100, height: 100), lineWidth: CGFloat, fillColor: UIColor, shapeBorderColor: UIColor) {
        super.init(origin: origin, size: size, lineWidth: lineWidth, fillColor: fillColor, shapeBorderColor: shapeBorderColor)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func createPath() -> UIBezierPath {
        let start = CGPoint(x: bounds.origin.x, y: bounds.height / 2)
        let end = CGPoint(x: bounds.width, y: bounds.height / 2)
        let tailWidth: CGFloat = 10
        let headWidth: CGFloat = 25
        let headLength: CGFloat = 40
        let length = hypot(end.x - start.x, end.y - start.y)
        let tailLength = length - headLength
        
        let points: [CGPoint] = [
            .init(x: 0, y: tailWidth / 2),
            .init(x: tailLength, y: tailWidth / 2),
            .init(x: tailLength, y: headWidth / 2),
            .init(x: length, y: 0),
            .init(x: tailLength, y: -headWidth / 2),
            .init(x: tailLength, y: -tailWidth / 2),
            .init(x: 0, y: -tailWidth / 2)
        ]

        let cosine = (end.x - start.x) / length
        let sine = (end.y - start.y) / length
        let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: start.y)

        let path = CGMutablePath()
        path.addLines(between: points, transform: transform)
        path.closeSubpath()
        
        return UIBezierPath(cgPath: path)
    }
}
