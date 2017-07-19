//
//  UINavigationController.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 18/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

extension UINavigationController {
    func presentViewControllerModally(_ vc: UIViewController, transitioningDelegate: SemiModalTransistioningDelegate? = nil) {
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        if transitioningDelegate != nil {
            nav.modalPresentationStyle = .custom
            nav.transitioningDelegate = transitioningDelegate
        }
        present(nav, animated: true, completion: nil)
    }
}
