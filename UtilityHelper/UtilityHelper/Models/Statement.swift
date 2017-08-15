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
    var otherAliasProperty: AliasProperty?
    
    var description: String {
        var valueText = values.toString()
        if argument.description == Argument.in.description {
            valueText = "(\(values.toString(separator: ", ")))"
        }
        else if argument.description == Argument.between.description {
            valueText = values.toString(separator: " AND ")
        }
        else if let otherAliasProperty = otherAliasProperty {
            valueText = otherAliasProperty.description
        }
        return " ".joined(contentsOf: [aliasProperty.description, argument.description, valueText])
    }
    
    init(aliasProperty: AliasProperty, argument: WhereArgument, value: Any) {
        self.aliasProperty = aliasProperty
        self.argument = argument
        self.values = [value]
    }
    
    init(aliasProperty: AliasProperty, argument: WhereArgument, values: [Any]) {
        self.aliasProperty = aliasProperty
        self.argument = argument
        self.values = values
    }
    
    init(aliasProperty: AliasProperty, argument: WhereArgument, otherAliasProperty: AliasProperty) {
        self.aliasProperty = aliasProperty
        self.argument = argument
        self.otherAliasProperty = otherAliasProperty
    }
}
