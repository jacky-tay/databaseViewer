//
//  TextFieldTableViewCell.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 24/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit
import CoreData

class TextFieldTableViewCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
    
    func updateContent(attributeType: NSAttributeType? = nil) {
        if let type = attributeType {
            textField.keyboardType = type.getKeyboardType()
        }
    }
}
