//
//  Statement.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 29/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

class Statement: CustomStringConvertible {
    var aliasProperty: AliasProperty!
    var argument: WhereArgument!
    var values: [Any] = []
    
    var description: String {
        var valueText = ""
        if argument.description == Argument.in.description {
            valueText = "(\(values.toString(separator: ", ")))"
        }
        else if argument.description == Argument.between.description {
            valueText = values.toString(separator: " AND ")
        }
        return " ".joined(contentsOf: [aliasProperty.description, argument.description, valueText])
    }
    
    init(aliasProperty: AliasProperty, argument: WhereArgument, values: [Any]) {
        self.aliasProperty = aliasProperty
        self.argument = argument
        self.values = values
    }
}
