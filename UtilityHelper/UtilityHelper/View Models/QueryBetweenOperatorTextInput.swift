//
//  QueryBetweenOperatorTextInput.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 25/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class QueryBetweenOperatorTextInput: QueryOperatorTextInput {
    
    private var firstText: String?
    private var secondText: String?
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? super.tableView(tableView, numberOfRowsInSection: section) : (firstText == nil ? 1 : 3)
    }
    
    override func doneIsClicked() {
        if let first = (delegate?.getCellRow(at: IndexPath(row: 0, section: 0)) as? TextFieldTableViewCell)?.textField.text,
            let second = (delegate?.getCellRow(at: IndexPath(row: 0, section: 0)) as? TextFieldTableViewCell)?.textField.text {
            let statement = Statement(aliasProperty: aliasProperty, argument: Argument.between, values: [first, second])
            queryRequest?.insertStatement(statement)
            queryRequest?.reload()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 1 {
            let cell = getCell(from: tableView, indexPath: indexPath)
            cell.textLabel?.text = "AND"
            cell.detailTextLabel?.text = nil
            cell.accessoryType = .none
            cell.selectionStyle = .none
            return cell
        }
        else if indexPath.section == 0, let cell = getTextFieldCell(from: tableView, indexPath: indexPath) {
            cell.textField.text = indexPath.row == 0 ? firstText : secondText
            return cell
        }
        else {
           return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let text = list[filteredList[indexPath.row]]
            if firstText == nil {
                firstText = text
                (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextFieldTableViewCell)?.textField.text = text
                delegate?.update(insertRows: [], insertSections: [1]) // TODO
            }
            else {
                secondText = text
                (tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? TextFieldTableViewCell)?.textField.text = text
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
