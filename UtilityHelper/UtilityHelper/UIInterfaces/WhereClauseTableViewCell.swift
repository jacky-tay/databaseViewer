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
        let prefix = NSMutableAttributedString()
        
//        for i in 0 ..< statement.prefix.count {
//            let color = (row == 0 && statement.prefix[i] == .bracketStart) || (row > 0 && i + 1 == statement.prefix.count) ? UIColor.darkText : UIColor.clear
//            prefix.append(NSAttributedString(string: statement.prefix[i].description, attributes: [NSForegroundColorAttributeName : color]))
//        }
        
        print(row, statement.prefix.map { $0.debugDesription() }.joined(separator: " "), statement.statement)
        
        prefixLabel.attributedText = prefix
        statementLabel.text = statement.statement
        suffixLabel.text = "" // TODO
    }
}
