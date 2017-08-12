//
//  ExecuteTableViewCell.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 13/08/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

protocol ExecuteTableViewCellDelegate: class {
    func execute()
    func getTintColor() -> UIColor
}

class ExecuteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var button: UIButton!
    private weak var delegate: ExecuteTableViewCellDelegate?
    
    func set(delegate: ExecuteTableViewCellDelegate) {
        self.delegate = delegate
        button.backgroundColor = delegate.getTintColor()
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
    }
    
    @IBAction func didClicked(_ sender: UIButton) {
        delegate?.execute()
    }
}
