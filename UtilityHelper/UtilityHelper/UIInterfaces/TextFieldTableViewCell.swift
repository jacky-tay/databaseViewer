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

    static let fromDate = "FromDate"
    static let toDate = "ToDate"
    @IBOutlet weak var textField: UITextField!
    
    func updateContent(attributeType: NSAttributeType, extraDetails: [String : Any]) {

        if attributeType == NSAttributeType.dateAttributeType {
            let datePicker = UIDatePicker()
            datePicker.addTarget(self, action: #selector(dateDidChanged(_:)), for: .valueChanged)
            datePicker.sizeToFit()
            datePicker.datePickerMode = .dateAndTime
            datePicker.minimumDate = (extraDetails[TextFieldTableViewCell.fromDate] as? Date)
            datePicker.maximumDate = (extraDetails[TextFieldTableViewCell.toDate] as? Date)
            textField.inputView = datePicker
        }
        else {
            textField.keyboardType = attributeType.getKeyboardType()
        }
    }

    private dynamic func dateDidChanged(_ sender: UIDatePicker) {
        let dateFormatter = DatabaseManager.sharedInstance.dateFormatter
        textField.text = dateFormatter.string(from: sender.date)
    }
}
