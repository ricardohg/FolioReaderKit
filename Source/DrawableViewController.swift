//
//  DrawableViewController.swift
//  FolioReaderKit
//
//  Created by ricardo hernandez  on 2/27/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import UIKit

class DrawableViewController: UIViewController {
    
    weak var cgView: StrokeCGView!
    var strokeCollection = StrokeCollection() {
        didSet {
            cgView?.strokeCollection = self.strokeCollection
        }
    }
    
    weak var canvasContainerView: CanvasContainerView!
    
    var strokeColor: UIColor = .black {
        didSet {
            cgView?.strokeColor = self.strokeColor
        }
    }
    
    var thinkness: Double = 3 {
        didSet {
            cgView?.strokeWidth = self.thinkness
        }
    }
    
    var eraseWidth: Double = 1.5 {
        didSet {
            cgView.eraserWidth = self.eraseWidth
        }
    }
    
    var style: StrokeViewDisplayOptions = .ink {
        didSet {
            cgView?.strokeStyle = self.style
        }
    }        
    
    var pencilStrokeRecognizer: StrokeGestureRecognizer!
    
    var saveImage: ((UIView) ->())?
    var didSelectShape: (() -> ())?
    private var currentShape: ShapeView?
    private var shapeViewOffset: CGFloat = 50.0
    
    // property to store previous drawed image
    weak var currentImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        
        let screenBounds = UIScreen.main.bounds
        let maxScreenDimension = max(screenBounds.width, screenBounds.height)
        
        let cgView = StrokeCGView(frame: CGRect(origin: .zero, size: CGSize(width: maxScreenDimension, height: maxScreenDimension)))
        cgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cgView.strokeColor = strokeColor
        self.cgView = cgView
        
        let canvasContainerView = CanvasContainerView(canvasSize: cgView.frame.size)
        canvasContainerView.documentView = cgView
        self.canvasContainerView = canvasContainerView
        
        view.addSubview(canvasContainerView)                
        
        cgView.strokeCollection = self.strokeCollection
        
        pencilStrokeRecognizer = setupStrokeGestureRecognizer(isForPencil: true)
        
        //single tap handler
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        singleTapGestureRecognizer.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(undo), name: .undoAction, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(redo), name: .redoAction, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func receivedAllUpdatesForStroke(_ stroke: Stroke) {
        cgView.setNeedsDisplay(for: stroke)
        stroke.clearUpdateInfo()
    }
    
    func saveToolState(for bookId: String, configuration: FolioReaderConfig) {
        ToolState.store(color: strokeColor, thickness: thinkness, bookId: bookId, configuration: configuration)
    }

    func loadToolState(for bookId: String, configuration: FolioReaderConfig) {
        if let toolState = ToolState.toolState(for: bookId, configuration: configuration) {
            strokeColor = UIColor.hexStringToUIColor(hex: toolState.colorHex)
            thinkness = Double(toolState.thickness)
        }
    }
    
    /// A helper method that creates stroke gesture recognizers.
    /// - Tag: setupStrokeGestureRecognizer
    func setupStrokeGestureRecognizer(isForPencil: Bool) -> StrokeGestureRecognizer {
        let recognizer = StrokeGestureRecognizer(target: self, action: #selector(strokeUpdated(_:)))
        recognizer.delegate = self
        recognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(recognizer)
        recognizer.coordinateSpaceView = cgView
        recognizer.isForPencil = isForPencil
        return recognizer
    }
    
    /// Handles the gesture for `StrokeGestureRecognizer`.
    /// - Tag: strokeUpdate
    @objc
    func strokeUpdated(_ strokeGesture: StrokeGestureRecognizer) {
        
        guard style != .eraser else {
            if let shapeView = strokeGesture.trackedTouch?.view as? ShapeView {                
                shapeView.removeFromSuperview()
                return
            }
            cgView.eraseStroke = strokeGesture.stroke
            return
        }
        
        if strokeGesture === pencilStrokeRecognizer {
            lastSeenPencilInteraction = Date()
        }
        
        var stroke: Stroke?
        if strokeGesture.state != .cancelled {
            stroke = strokeGesture.stroke
            if strokeGesture.state == .began ||
                (strokeGesture.state == .ended && strokeCollection.activeStroke == nil) {
                strokeCollection.activeStroke = stroke
            }
        } else {
            strokeCollection.activeStroke = nil
        }
        
        if let stroke = stroke {
            if strokeGesture.state == .ended {
                if strokeGesture === pencilStrokeRecognizer {
                    // Make sure we get the final stroke update if needed.
                    stroke.receivedAllNeededUpdatesBlock = { [weak self] in
                        self?.receivedAllUpdatesForStroke(stroke)
                    }
                }
                strokeCollection.takeActiveStroke()
            }
        }
        
        cgView.strokeCollection = strokeCollection
        
    }
    
    @objc func handleSingleTap(_ sender: Any) {
        drawExistingShapes()
        saveImage?(view)
    }
    
    // MARK: Pencil Recognition and UI Adjustments
    /*
     Since usage of the Apple Pencil can be very temporary, the best way to
     actually check for it being in use is to remember the last interaction.
     Also make sure to provide an escape hatch if you modify your UI for
     times when the pencil is in use vs. not.
     */
    
    // Timeout the pencil mode if no pencil has been seen for 5 minutes and the app is brought back in foreground.
    let pencilResetInterval = TimeInterval(60.0 * 5)
    
    var lastSeenPencilInteraction: Date?
    
    func shouldTimeoutPencilMode() -> Bool {
        guard let lastSeenPencilInteraction = self.lastSeenPencilInteraction else { return true }
        return abs(lastSeenPencilInteraction.timeIntervalSinceNow) > self.pencilResetInterval
    }

}

// MARK: -- Undo Operations

extension DrawableViewController {
    
    @objc func undo() {
        guard cgView.strokeCollection?.strokes.count > 0, let stroke = cgView.strokeCollection?.strokes.removeLast() else {
        return
        }
        cgView.strokeCollection?.undoStrokes.append(stroke)
        cgView.setNeedsDisplay()
    }
    
    @objc func redo() {
        
        guard let collection = cgView.strokeCollection, collection.undoStrokes.count > 0 else {
            return
        }
        
        let stroke = collection.undoStrokes.removeLast()
        cgView.strokeCollection?.strokes.append(stroke)
        cgView.setNeedsDisplay()

    }
}


// MARK: - Shape Operations -
extension DrawableViewController {
    func drawShape(viewModel: ShapeViewModel) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.shapeSelected))
        var center = self.view.center
        for view in view.subviews.filter({ $0 is ShapeView }) {
            if center == view.center {
                center.x += shapeViewOffset
            }
        }
        let shape: ShapeView = ShapeView(center: center, viewModel: viewModel)
        
        shape.addGestureRecognizer(tapGesture)
        self.view.addSubview(shape)
        self.currentShape = shape
    }
    
    func modifyCurrentShape(viewModel: ShapeViewModel) {
        guard let shape = self.currentShape else {
            drawShape(viewModel: viewModel)
            return
        }
        shape.change(lineWidth: viewModel.borderWidth, fillColor: viewModel.fillColor, shapeBorderColor: viewModel.borderColor)
    }
    
    func deselectCurrentShape() {
        currentShape = nil
    }
    
    @objc private func shapeSelected(sender: UITapGestureRecognizer) {
        currentShape = (sender.view as? ShapeView)
        didSelectShape?()
    }
    
    private func drawExistingShapes() {
        currentShape = nil
        let views = view.subviews.compactMap({ ($0 as? ShapeView) })
        views.forEach({
            draw(shape: $0)
            $0.removeFromSuperview()
        })        
    }
    
    private func draw(shape: ShapeView) {
        let shapePath = Shape(
            path: shape.path,
            backgroundColor: shape.fillColor,
            borderColor: shape.shapeBorderColor,
            borderWidth: shape.lineWidth
        )
        
        let stroke = Stroke(shape: shapePath)
        let originFrameSample = StrokeSample(timestamp: Date().timeIntervalSinceNow, location: shape.frame.origin, coalesced: true)
        let frameSample = StrokeSample(timestamp: Date().timeIntervalSinceNow, location: CGPoint(x:shape.frame.origin.x + shape.frame.width, y: shape.frame.origin.y + shape.frame.height), coalesced: false)
        stroke.samples.append(originFrameSample)
        stroke.samples.append(frameSample)
        strokeCollection.activeStroke = stroke
        strokeCollection.takeActiveStroke()
        cgView.strokeCollection = strokeCollection
        cgView.setNeedsDisplay()
    }
}

extension DrawableViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is ShapeView && style == .ink {
            return false
        }
        
        return true
    }
}
