//
//  DatabaseAliasTable.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 30/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

class DatabaseAliasTable : DatabaseTable, CustomStringConvertible {
    var alias: String!
    
    var description: String {
        return " AS ".joined(contentsOf: [tableName, alias])
    }
    
    init(databaseName: String, tableName: String, alias: String) {
        self.alias = alias
        super.init(databaseName: databaseName, tableName: tableName)
    }
    
    func toAliasTable() -> AliasTable? {
        return DatabaseManager.sharedInstance.getTable(from: self)?.toAliasTable(alias: alias)
    }
    
    func toJoinByDatabaseAlias(join: Join, with other: DatabaseAliasTable, onConditions: [JoinWithDatabaseAliasTable]?) -> JoinByDatabaseAlias {
        return JoinByDatabaseAlias(databaseName: databaseName, tableName: tableName, alias: alias, join: join, otherTable: other, onConditions: onConditions)
    }
    
    func toDatabaseAliasTable(with properties: [Property]) -> DatabaseAliasTableWithProperties {
        return DatabaseAliasTableWithProperties(databaseName: databaseName, tableName: tableName, alias: alias, properties: properties)
    }
}
