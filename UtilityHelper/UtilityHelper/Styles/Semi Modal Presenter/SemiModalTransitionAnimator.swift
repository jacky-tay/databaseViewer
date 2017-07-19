//
//  SemiModalTransitionAnimator.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 19/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class SemiModalTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    @objc func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            transitionContext.viewController(forKey: .from)?.view.frame.origin.y = UIScreen.main.bounds.height
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
}
