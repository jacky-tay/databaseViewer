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
    
    func updateContent(statement: WhereClauseStatement, row: Int) {
                
        print(row,
              statement.prefix.map { $0.debugDesription() }.joined(separator: " "),
              statement.statement,
              statement.suffix.map { $0.debugDesription() }.joined(separator: " "))
        
        let display = WhereClause.getDisplayDescription(statement: statement)
        
        prefixLabel.attributedText = display?.prefix
        statementLabel.text = statement.statement
        suffixLabel.attributedText = display?.suffix
    }
}
