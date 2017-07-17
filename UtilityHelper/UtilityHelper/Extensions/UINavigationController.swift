//
//  UINavigationController.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 18/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

extension UINavigationController {
    func presentViewControllerModally(_ vc: UIViewController) {
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        present(nav, animated: true, completion: nil)
    }
}

