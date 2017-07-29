//
//  DatabaseAliasTableWithProperties.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 30/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

class DatabaseAliasTableWithProperties: DatabaseAliasTable {
    let properties: [Property]!
    
    init(databaseName: String, tableName: String, alias: String, properties: [Property]) {
        self.properties = properties
        super.init(databaseName: databaseName, tableName: tableName, alias: alias)
    }
}
