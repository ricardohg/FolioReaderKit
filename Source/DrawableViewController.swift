//
//  DrawableViewController.swift
//  FolioReaderKit
//
//  Created by ricardo hernandez  on 2/27/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import UIKit

class DrawableViewController: UIViewController {
    
    var cgView: StrokeCGView!
    var strokeCollection = StrokeCollection()
    var canvasContainerView: CanvasContainerView!
    
    var pencilStrokeRecognizer: StrokeGestureRecognizer!
    
    var saveImage: ((UIView) ->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(undo), name: .undoAction, object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(redo), name: .redoAction, object: nil)

        view.backgroundColor = .clear
        
        let screenBounds = UIScreen.main.bounds
        let maxScreenDimension = max(screenBounds.width, screenBounds.height)
        
        let cgView = StrokeCGView(frame: CGRect(origin: .zero, size: CGSize(width: maxScreenDimension, height: maxScreenDimension)))
        cgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.cgView = cgView
        
        let canvasContainerView = CanvasContainerView(canvasSize: cgView.frame.size)
        canvasContainerView.documentView = cgView
        self.canvasContainerView = canvasContainerView
        
        view.addSubview(canvasContainerView)
        
        pencilStrokeRecognizer = setupStrokeGestureRecognizer(isForPencil: true)
        
        //single tap handler
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        singleTapGestureRecognizer.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTapGestureRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func receivedAllUpdatesForStroke(_ stroke: Stroke) {
        cgView.setNeedsDisplay(for: stroke)
        stroke.clearUpdateInfo()
    }

    
    /// A helper method that creates stroke gesture recognizers.
    /// - Tag: setupStrokeGestureRecognizer
    func setupStrokeGestureRecognizer(isForPencil: Bool) -> StrokeGestureRecognizer {
        let recognizer = StrokeGestureRecognizer(target: self, action: #selector(strokeUpdated(_:)))
        //recognizer.delegate = self
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


