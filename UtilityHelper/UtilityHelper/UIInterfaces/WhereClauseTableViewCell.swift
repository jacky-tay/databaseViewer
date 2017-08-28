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
        let prefixString = NSMutableAttributedString()
        
        var preList = [WhereCategoryDisplay]()
        for pre in statement.prefix.enumerated() {
            var show = false
            if let andOr = pre.element.getAndOrIndexCount() {
                show = andOr.index != 0
                if show && pre.offset + 1 < statement.prefix.count, let bracket = statement.prefix[pre.offset + 1].getBracketIndex() {
                    show = bracket == 0
                }
                preList = preList.update(to: (andOr.index - andOr.count))
            }
            else if let bracket = pre.element.getBracketIndex() {
                show = bracket == 0
                preList.append(.bracketStart(-1))
            }
            let color = show ? UIColor.darkText : UIColor.clear
            prefixString.append(NSAttributedString(string: pre.element.description, attributes: [NSForegroundColorAttributeName : color]))
        }
        
        preList = preList.reversed()
        let suffixString = NSMutableAttributedString()
        for pre in preList.enumerated() {
            var show = true
            
            if let preIndex = pre.element.getBracketIndex() {
                let suffix = preList.prefix(pre.offset)
                for s in suffix {
                    if let bracket = s.getBracketIndex(), bracket != -1 {
                        show = false
                    }
                }
                show = show && preIndex == -1
            }
            let color = show ? UIColor.darkText : UIColor.clear
            suffixString.append(NSAttributedString(string: ")", attributes: [NSForegroundColorAttributeName : color]))
        }
        
        print(row,
              statement.prefix.map { $0.debugDesription() }.joined(separator: " "),
              statement.statement,
              statement.suffix.map { $0.debugDesription() }.joined(separator: " "))
        
        prefixLabel.attributedText = prefixString
        statementLabel.text = statement.statement
        suffixLabel.attributedText = suffixString
    }
}
