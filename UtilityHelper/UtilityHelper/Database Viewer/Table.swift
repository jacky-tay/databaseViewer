//
//  Table.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 17/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import CoreData
import Foundation

class Property {
    let name: String!
    let attributeType: NSAttributeType!
    
    init(name: String, attributeType: NSAttributeType) {
        self.name = name
        self.attributeType = attributeType
    }
}

class Table {
    let databaseName: String
    let name: String
    var count: Int = 0
    let properties: [Property]
    let relationships: [String]?

    init(databaseName: String, name: String, properties: [Property], relationships: [String]? = nil) {
        self.databaseName = databaseName
        self.name = name
        self.properties = properties
        self.relationships = relationships?.sorted()
    }

    func toSelectedTable(alias: String? = nil) -> SelectedTable {
        let table = SelectedTable(databaseName: databaseName, name: name, properties: properties, relationships: relationships)
        table.alias = alias
        return table
    }
    
    func toDatabaseTable(alias: String?) -> DatabaseTableAlias {
        return DatabaseTableAlias(databaseName: databaseName, tableName: name, alias: alias)
    }
}

class SelectedTable: Table {
    var alias: String?
    
    func propertiesToAliasProperties() -> [AliasProperty] {
        return properties.map { AliasProperty(alias: alias, propertyName: $0.name) }
    }
    
    func toDatabaseTableAlias() -> DatabaseTableAlias {
        return toDatabaseTable(alias: alias)
    }
}
