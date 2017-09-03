//
//  Statement.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 29/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import CoreData
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
    
    func toNSPredicate(filterBy tableAlias: String?) -> NSPredicate? {
        guard aliasProperty.alias == tableAlias, let propertyName = aliasProperty.propertyName else {
            return nil
        }
        if argument.description == Argument.isNull.description {
            return NSPredicate(format: "%K = nil", propertyName)
        }
        else if argument.description == Argument.isNotNull.description {
            return NSPredicate(format: "%K != nil", propertyName)
        }
        else if argument.description == Argument.in.description {
            let descriptions = values.flatMap { ($0 as? AnyObject)?.description }
            return NSCompoundPredicate(orPredicateWithSubpredicates: descriptions.map { NSPredicate(format: "%K = %@", propertyName, $0) })
        }
        else if let value = (values.first as? AnyObject)?.description {
            return NSPredicate(format: "%K \(argument.description) %@", propertyName, value)
        }
        return nil
    }
}
