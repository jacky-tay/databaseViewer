//
//  SemiModalTransistioningDelagate.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 19/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class SemiModalTransistioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SemiModalTransitionAnimator()
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SemiModalPresentationController(presentedViewController: presented, presenting: presenting)
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
}
