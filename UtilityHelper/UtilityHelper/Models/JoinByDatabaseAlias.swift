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
    var onConditions: WhereClause?
    
    init(databaseName: String, tableName: String, alias: String, join: Join, otherTable: DatabaseAliasTable, onConditions: WhereClause?) {
        self.joinType = join
        self.otherTable = otherTable
        self.onConditions = onConditions
        super.init(databaseName: databaseName, tableName: tableName, alias: alias)
    }
    
    func insert(clause: WhereClause) {
        if onConditions == nil {
            onConditions = clause
        }
        else if let selected = onConditions, WhereClause.canAppend(lhs: selected, rhs: clause) {
            onConditions = selected.append(whereClause: clause)
        }
        else if let selected = onConditions, WhereClause.shouldInsert(lhs: selected, rhs: clause) {
            onConditions = clause.insert(whereClause: selected)
        }
    }
}
