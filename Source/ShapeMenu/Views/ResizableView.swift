//
//  ResizableView.swift
//  Resizable
//
//  Created by Caroline on 6/09/2014.
//  Copyright (c) 2014 Caroline. All rights reserved.
//

import UIKit

class ResizableView: UIView {
    
    var topLeft:DragHandle!
    var topRight:DragHandle!
    var bottomLeft:DragHandle!
    var bottomRight:DragHandle!
    var rotateHandle:DragHandle!
    var previousLocation = CGPoint.zero
    var rotateLine = CAShapeLayer()
    
    
    override func didMoveToSuperview() {
        let resizeFillColor = UIColor.cyan
        let resizeStrokeColor = UIColor.black
        let rotateFillColor = UIColor.orange
        let rotateStrokeColor = UIColor.black
        topLeft = DragHandle(fillColor:resizeFillColor, strokeColor: resizeStrokeColor)
        topRight = DragHandle(fillColor:resizeFillColor, strokeColor: resizeStrokeColor)
        bottomLeft = DragHandle(fillColor:resizeFillColor, strokeColor: resizeStrokeColor)
        bottomRight = DragHandle(fillColor:resizeFillColor, strokeColor: resizeStrokeColor)
        rotateHandle = DragHandle(fillColor:rotateFillColor, strokeColor:rotateStrokeColor)
        
        rotateLine.opacity = 0.0
        rotateLine.lineDashPattern = [3,2]
        
        superview?.addSubview(topLeft)
        superview?.addSubview(topRight)
        superview?.addSubview(bottomLeft)
        superview?.addSubview(bottomRight)
        superview?.addSubview(rotateHandle)
        self.layer.addSublayer(rotateLine)
        
        
        var pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        topLeft.addGestureRecognizer(pan)
        pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        topRight.addGestureRecognizer(pan)
        pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        bottomLeft.addGestureRecognizer(pan)
        pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        bottomRight.addGestureRecognizer(pan)
        pan = UIPanGestureRecognizer(target: self, action: #selector(handleRotate))
        rotateHandle.addGestureRecognizer(pan)
        pan = UIPanGestureRecognizer(target: self, action: #selector(handleMove))
        self.addGestureRecognizer(pan)
        
        self.updateDragHandles()
    }
    
    func updateDragHandles() {
        topLeft.center = self.transformedTopLeft()
        topRight.center = self.transformedTopRight()
        bottomLeft.center = self.transformedBottomLeft()
        bottomRight.center = self.transformedBottomRight()
        rotateHandle.center = self.transformedRotateHandle()
    }
    
    //MARK: - Gesture Methods
    
    @objc func handleMove(gesture:UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview!)
        
        var center = self.center
        center.x += translation.x
        center.y += translation.y
        self.center = center
        
        gesture.setTranslation(CGPoint.zero, in: self.superview!)
        updateDragHandles()
    }
    
    func angleBetweenPoints(startPoint:CGPoint, endPoint:CGPoint)  -> CGFloat {
        let a = startPoint.x - self.center.x
        let b = startPoint.y - self.center.y
        let c = endPoint.x - self.center.x
        let d = endPoint.y - self.center.y
        let atanA = atan2(a, b)
        let atanB = atan2(c, d)
        return atanA - atanB
        
    }
    
    func drawRotateLine(fromPoint:CGPoint, toPoint:CGPoint) {
        let linePath = UIBezierPath()
        linePath.move(to: fromPoint)
        linePath.addLine(to: toPoint)
        rotateLine.path = linePath.cgPath
        rotateLine.fillColor = nil
        rotateLine.strokeColor = UIColor.orange.cgColor
        rotateLine.lineWidth = 2.0
        rotateLine.opacity = 1.0
    }
    
    @objc func handleRotate(gesture:UIPanGestureRecognizer) {
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
        previousLocation = location
        self.updateDragHandles()
    }
    
    @objc func handlePan(gesture:UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
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
        if gesture.state == .ended {
            self.setAnchorPoint(anchorPoint: CGPoint(x: 0.5, y: 0.5))
        }        
    }
}


//
//  DragHandle.swift
//  Resizable
//
//  Created by Caroline on 7/09/2014.
//  Copyright (c) 2014 Caroline. All rights reserved.
//

let diameter:CGFloat = 40

import UIKit

class DragHandle: UIView {
    
    var fillColor = UIColor.darkGray
    var strokeColor = UIColor.lightGray
    var strokeWidth:CGFloat = 2.0
    
    required init(coder aDecoder: NSCoder) {
        fatalError("Use init(fillColor:, strokeColor:)")
    }
    
    init(fillColor:UIColor, strokeColor:UIColor, strokeWidth width:CGFloat = 2.0) {
        super.init(frame:CGRect(x: 0, y: 0, width: diameter, height: diameter))
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        self.strokeWidth = width
        self.backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect)
    {
        super.draw(rect)
        let handlePath = UIBezierPath(ovalIn: rect.insetBy(dx: 10 + strokeWidth, dy: 10 + strokeWidth))
        fillColor.setFill()
        handlePath.fill()
        strokeColor.setStroke()
        handlePath.lineWidth = strokeWidth
        handlePath.stroke()
    }
}


//
//  UIView+Transform.swift
//  Resizable
//
//  Created by Caroline on 6/09/2014.
//  Copyright (c) 2014 Caroline. All rights reserved.
//

//Credits:
//Erica Sadun: http://www.informit.com/articles/article.aspx?p=1951182
//Brad Larson / Magnus: http://stackoverflow.com/a/5666430/359578

import Foundation
import UIKit

extension UIView {
    
    func offsetPointToParentCoordinates(point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x + self.center.x, y: point.y + self.center.y)
    }
    
    func pointInViewCenterTerms(point:CGPoint) -> CGPoint {
        return CGPoint(x: point.x - self.center.x, y: point.y - self.center.y)
    }
    
    func pointInTransformedView(point: CGPoint) -> CGPoint {
        let offsetItem = self.pointInViewCenterTerms(point: point)
        let updatedItem = offsetItem.applying(self.transform)
        let finalItem = self.offsetPointToParentCoordinates(point: updatedItem)
        return finalItem
    }
    
    func originalFrame() -> CGRect {
        let currentTransform = self.transform
        self.transform = CGAffineTransform.identity
        let originalFrame = self.frame
        self.transform = currentTransform
        return originalFrame
    }
    
    //These four methods return the positions of view elements
    //with respect to the current transformation
    
    func transformedTopLeft() -> CGPoint {
        let frame = self.originalFrame()
        let point = frame.origin
        return self.pointInTransformedView(point: point)
    }
    
    func transformedTopRight() -> CGPoint {
        let frame = self.originalFrame()
        var point = frame.origin
        point.x += frame.size.width
        return self.pointInTransformedView(point: point)
    }
    
    func transformedBottomRight() -> CGPoint {
        let frame = self.originalFrame()
        var point = frame.origin
        point.x += frame.size.width
        point.y += frame.size.height
        return self.pointInTransformedView(point: point)
    }
    
    func transformedBottomLeft() -> CGPoint {
        let frame = self.originalFrame()
        var point = frame.origin
        point.y += frame.size.height
        return self.pointInTransformedView(point: point)
    }
    
    func transformedRotateHandle() -> CGPoint {
        let frame = self.originalFrame()
        var point = frame.origin
        point.x += frame.size.width + 40
        point.y += frame.size.height / 2
        return self.pointInTransformedView(point: point)
    }
    
    func setAnchorPoint(anchorPoint:CGPoint) {
        var newPoint = CGPoint(x: self.bounds.size.width * anchorPoint.x, y: self.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: self.bounds.size.width * self.layer.anchorPoint.x, y: self.bounds.size.height * self.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(self.transform)
        oldPoint = oldPoint.applying(self.transform)
        
        var position = self.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        self.layer.position = position
        self.layer.anchorPoint = anchorPoint
    }
    
}
