//
//  CanvasContainerView.swift
//  Eduac
//
//  Created by ricardo hernandez  on 2/22/19.
//  Copyright © 2019 webcat. All rights reserved.
//

/*Abstract:
 The content of the scroll view. Adds some margin and a shadow. Setting the documentView places this view, and sizes it to the canvasSize.
 */

import UIKit

open class CanvasContainerView: UIView {
    let canvasSize: CGSize
    
    let canvasView: UIView
    
    public var documentView: UIView? {
        willSet {
            if let previousView = documentView {
                previousView.removeFromSuperview()
            }
        }
        didSet {
            if let newView = documentView {
                newView.frame = canvasView.bounds
                canvasView.addSubview(newView)
            }
        }
    }
    
    required public init(canvasSize: CGSize) {
        let screenBounds = UIScreen.main.bounds
        let minDimension = max(screenBounds.width, screenBounds.height)
        self.canvasSize = canvasSize
        
        var size = canvasSize
        size.width = max(minDimension, size.width)
        size.height = max(minDimension, size.height)
        
        let frame = CGRect(origin: .zero, size: size)
        
        let canvasOrigin = CGPoint(x: (frame.width - canvasSize.width) / 2.0, y: (frame.height - canvasSize.height) / 2.0)
        let canvasFrame = CGRect(origin: canvasOrigin, size: canvasSize)
        canvasView = UIView(frame: canvasFrame)
        canvasView.backgroundColor = UIColor.red
        canvasView.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        canvasView.layer.shadowRadius = 4.0
        canvasView.layer.shadowColor = UIColor.darkGray.cgColor
        canvasView.layer.shadowOpacity = 1.0
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.red
        self.addSubview(canvasView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

