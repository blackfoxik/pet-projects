//
//  TipsAnimator.swift
//  iTunesArtworkSearcher
//
//  Created by Anton on 13.10.17.
//  Copyright © 2017 Anton. All rights reserved.
//

import UIKit

// MARK: - this class response for transition animation for tips window
class TipsAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration = 1.0
    var presenting = true
    var originFrame = CGRect.zero
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)
        let fromView = transitionContext.view(forKey: .from)
        let tipView = presenting ? toView : fromView
        let initialFrame = presenting ? originFrame : tipView?.frame
        let finalFrame = presenting ? tipView?.frame : originFrame
        let xScaleFactor = presenting ?
            (initialFrame?.width)! / (finalFrame?.width)! :
            (finalFrame?.width)! / (initialFrame?.width)!
        let yScaleFactor = presenting ?
            (initialFrame?.height)! / (finalFrame?.height)! :
            (finalFrame?.height)! / (initialFrame?.height)!
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        if presenting {
            tipView?.transform = scaleTransform
            tipView?.center = CGPoint(x: (initialFrame?.midX)!, y: (initialFrame?.midY)!)
            tipView?.clipsToBounds = true
            fromView?.alpha = 0.5
        } else {
            toView?.alpha = 1
        }
        containerView.addSubview(toView!)
        containerView.bringSubview(toFront: tipView!)
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, animations: {
            tipView?.transform = self.presenting ?
                CGAffineTransform.identity : scaleTransform
            if self.presenting {
                let size = CGSize(width: (tipView?.frame.width)! * 2 / 2.5, height: (tipView?.frame.height)! / 3)
                tipView?.frame.size = size
                let center = CGPoint(x: (fromView?.frame.midX)!, y: (fromView?.frame.midY)!)
                tipView?.center = center
            } else {
                tipView?.center = CGPoint(x: (finalFrame?.midX)!, y: (finalFrame?.midY)!)
            }
            
        }, completion: { _ in
            transitionContext.completeTransition(true)
            if self.presenting {
                containerView.addSubview(fromView!)
                containerView.bringSubview(toFront: tipView!)
            }
        })
        
    }
    
    
}
