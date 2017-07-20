//
//  NSMutableAttributedString.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 21/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    
    class func build(from components: [(string: String?, color: UIColor?)]) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString()
        for component in components {
            if let text = component.string, let color = component.color {
                attributedString.append(NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName : color]))
            }
            else if let text = component.string {
                attributedString.append(NSAttributedString(string: text))
            }
        }
        return attributedString
    }
}
