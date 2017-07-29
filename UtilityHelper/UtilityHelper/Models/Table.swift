//
//  Table.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 17/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

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

    func toAliasTable(alias: String? = nil) -> AliasTable {
        let table = AliasTable(databaseName: databaseName, name: name, properties: properties, relationships: relationships)
        table.alias = alias
        return table
    }
    
    func toDatabaseTable(alias: String) -> DatabaseAliasTable {
        return DatabaseAliasTable(databaseName: databaseName, tableName: name, alias: alias)
    }
    
    func toDatabaseAliasTableWithPropertiesRelationships() -> DatabaseAliasTableWithPropertiesRelationships {
        return DatabaseAliasTableWithPropertiesRelationships(databaseName: databaseName, tableName: name, properties: properties, relationships: relationships)
    }
}
