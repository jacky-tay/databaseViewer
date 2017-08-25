//
//  QueryWhereOperatorTextInput.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 19/08/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

class QueryWhereOperatorTextInput: QueryOperatorTextInput {
    
    var whereOption: WhereOptions?
    var endLastBracket: Bool?
    
    convenience init(queryRequest: QueryRequest, aliasProperty: AliasProperty, whereArgument: WhereArgument, whereOption: WhereOptions?, endLastBracket: Bool?) {
        self.init(queryRequest: queryRequest, aliasProperty: aliasProperty, whereArgument: whereArgument)
        self.whereOption = whereOption
        self.endLastBracket = endLastBracket
    }
    
    override func viewDidLoad(_ viewController: GenericTableViewController) {
        super.viewDidLoad(viewController)
        addDoneOnRightHandSide(viewController)
    }
    
    func doneIsClicked() {
        if let cell = delegate?.getCellRow(at: IndexPath(row: 0, section: 0)) as? TextFieldTableViewCell,
            let text = cell.textField.text {
            let statement = Statement(aliasProperty: aliasProperty, argument: whereArgument, values: [text])
            queryRequest?.insert(statement: statement, whereOption: whereOption, endLastBracket: endLastBracket)
            queryRequest?.reload()
        }
    }
}
