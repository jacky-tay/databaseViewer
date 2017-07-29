//
//  JoinByDatabaseAlias.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 30/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

class JoinByDatabaseAlias : DatabaseAliasTable {
    let joinType: Join!
    let otherTable: DatabaseAliasTable!
    var onConditions: [JoinWithDatabaseAliasTable]?
    
    init(databaseName: String, tableName: String, alias: String, join: Join, otherTable: DatabaseAliasTable, onConditions: [JoinWithDatabaseAliasTable]?) {
        self.joinType = join
        self.otherTable = otherTable
        self.onConditions = onConditions
        super.init(databaseName: databaseName, tableName: tableName, alias: alias)
    }
    
    func getConditionDescription(at index: Int) -> String {
        guard let conditions = onConditions else {
            return ""
        }
        let condition = conditions[index]
        let otherProperty = ".".joined(contentsOf: [otherTable.alias, condition.otherTableProperty])
        let property = ".".joined(contentsOf: [alias, condition.propertyName])
        return " ".joined(contentsOf: [otherProperty, condition.comparator?.description, property])
    }
}
