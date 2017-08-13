//
//  WhereClauseTableViewCell.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 13/08/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class WhereClauseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var prefixLabel: UILabel!
    @IBOutlet weak var statementLabel: UILabel!
    @IBOutlet weak var suffixLabel: UILabel!
    
    func updateContent(statement: WhereClauseStatement) {
        prefixLabel.text = "" // TODO
        statementLabel.text = statement.statement
        suffixLabel.text = "" // TODO
    }
}
