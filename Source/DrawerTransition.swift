//
//  PartialModalTrasition.swift
//  FolioReaderKit
//
//  Created by ricardo hernandez  on 5/7/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import UIKit

final class DrawerTransition: NSObject {
    
    enum TransitionType {
        case presenting
        case dismissing
    }
    
    fileprivate let transitionDuration = 0.3
    fileprivate let viewWidth: CGFloat = 310
    fileprivate var type: TransitionType
    
    init(withType type: TransitionType) {
        self.type = type
        super.init()
    }
}

extension DrawerTransition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        switch self.type {
        case .presenting:
            self.presentTransition(with: transitionContext)
        case .dismissing:
            self.dismissTransition(with: transitionContext)
        }
        
    }
    
    private func presentTransition(with transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to) else {
                return
        }
        
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        
        toViewController.view.frame = CGRect(x: -viewWidth, y: 0, width: viewWidth, height: finalFrame.size.height)
        containerView.insertSubview(toViewController.view, aboveSubview: fromViewController.view)
        
        UIView.animate(withDuration: self.transitionDuration, animations: {
            toViewController.view.transform = CGAffineTransform(translationX: self.viewWidth, y: 0)
            fromViewController.view.alpha = 0.5
        }) { (completed) in
            transitionContext.completeTransition(completed)
        }
        
    }
    
    private func dismissTransition(with transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: .from)
        let toViewController = transitionContext.viewController(forKey: .to)
        
        guard let frame = fromViewController?.view.frame else { return }
        
        UIView.animate(withDuration: self.transitionDuration, animations: {
            toViewController?.view.alpha = 1.0
            fromViewController?.view.transform = CGAffineTransform(translationX: -frame.width, y: 0)
        }) { (completed) in
            transitionContext.completeTransition(completed)
        }
        
    }
}
