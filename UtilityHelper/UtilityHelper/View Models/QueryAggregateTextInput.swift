//
//  QueryAggregateTextInput.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 28/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class QueryAggregateTextInput: QueryOperatorTextInput {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        (cell as? TextFieldTableViewCell)?.textField.becomeFirstResponder()
        return cell
    }
}
