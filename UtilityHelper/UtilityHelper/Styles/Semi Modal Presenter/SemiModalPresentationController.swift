//
//  SemiModalPresentationController.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 19/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class SemiModalPresentationController: UIPresentationController {

    private let heightRatio: CGFloat = 0.75
    
    override var frameOfPresentedViewInContainerView: CGRect {
        return CGRect(x: 0, y: containerView!.bounds.height * (1 - heightRatio), width: containerView!.bounds.width, height: containerView!.bounds.height * heightRatio)
    }

    override func presentationTransitionWillBegin() {
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] (context) -> Void in
            self?.presentingViewController.view.alpha = 0.5
            self?.presentingViewController.view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] (context) -> Void in
            self?.presentingViewController.view.transform = CGAffineTransform.identity
            self?.presentingViewController.view.alpha = 1
            }, completion: nil)
    }

    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
}
