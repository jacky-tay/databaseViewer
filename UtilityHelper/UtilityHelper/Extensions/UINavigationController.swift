//
//  UINavigationController.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 18/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

protocol InterceptableViewController {
    func canIntercept() -> Bool
}

extension UINavigationController: UINavigationBarDelegate, UIGestureRecognizerDelegate {

    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    func presentViewControllerModally(_ vc: UIViewController?, transitioningDelegate: SemiModalTransistioningDelegate? = nil) {
        guard let vc = vc else {
            return
        }
        
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        if transitioningDelegate != nil {
            nav.modalPresentationStyle = .custom
            nav.transitioningDelegate = transitioningDelegate
        }
        present(nav, animated: true, completion: nil)
    }

    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {

        if viewControllers.count < navigationBar.items?.count {
            return true
        }

        var canIntercept = false
        if let viewController = topViewController as? InterceptableViewController {
            canIntercept = viewController.canIntercept()
        }
        if !canIntercept {
            DispatchQueue.main.async { [weak self] in let _ = self?.popViewController(animated: true) }
        }
        else {
            for view in navigationBar.subviews {
                view.alpha = 1.0
            }
        }
        return !canIntercept
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        var shouldBegin = true
        if let viewController = topViewController as? InterceptableViewController {
            shouldBegin = !viewController.canIntercept()
        }
        return shouldBegin
    }
}
