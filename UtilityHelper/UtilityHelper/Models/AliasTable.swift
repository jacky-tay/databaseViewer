//
//  AliasTable.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 29/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

class AliasTable: Table {
    var alias: String!
    
    func propertiesToAliasProperties() -> [AliasProperty] {
        return properties.map { AliasProperty(alias: alias, propertyName: $0.name) }
    }
    
    func toDatabaseAliasTable() -> DatabaseAliasTable {
        return toDatabaseTable(alias: alias)
    }
    
    func toDatabaseAliasTableWithProperties(includeWildCard: Bool) -> DatabaseAliasTableWithProperties {
        var propertieStrings = properties.flatMap { $0 }
        if includeWildCard {
            propertieStrings.insert(Property(name: "*", attributeType: .undefinedAttributeType), at: 0)
        }
        return toDatabaseAliasTable().toDatabaseAliasTable(with: propertieStrings)
    }
}
