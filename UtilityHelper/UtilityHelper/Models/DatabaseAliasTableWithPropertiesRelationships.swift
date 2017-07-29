//
//  DatabaseAliasTableWithPropertiesRelationships.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 30/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

class DatabaseAliasTableWithPropertiesRelationships: DatabaseTable {
    let properties: [Property]!
    let relationships: [String]!
    
    init(databaseName: String, tableName: String, properties: [Property], relationships: [String]?) {
        self.properties = properties
        self.relationships = relationships ?? []
        super.init(databaseName: databaseName, tableName: tableName)
    }
}
