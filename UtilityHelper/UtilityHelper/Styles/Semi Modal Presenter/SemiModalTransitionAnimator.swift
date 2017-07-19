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
        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            transitionContext.viewController(forKey: .from)?.view.frame.origin.y = 1024
        }
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
}
