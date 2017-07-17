//
//  UICollectionViewLayoutAttributesExtension.swift
//  DatabaseViewer
//
//  Created by Jacky Tay on 6/07/17.
//  Copyright © 2017 SmudgeApps. All rights reserved.
//

import UIKit

extension UICollectionViewLayoutAttributes {

    func updateOriginX(_ x: CGFloat) {
        var _frame = self.frame
        _frame.origin.x = x
        self.frame = _frame
    }

    func updateOriginY(_ y: CGFloat) {
        var _frame = self.frame
        _frame.origin.y = y
        self.frame = _frame
    }
}
