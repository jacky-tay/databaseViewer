//
//  UIViewExtension.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 19/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

extension UIView {
    func applyRoundCorner(to corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.frame = bounds
        mask.path = path.cgPath
        layer.mask = mask
    }
}
