//
//  DatabaseTableJoinSelect.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 22/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class DatabaseTableJoinSelect: DatabaseTableSelect {
    
    private let relationshipTitle = "Relationships"
    private weak var queryRequest: QueryRequest?
    private let selectedTable: DatabaseTableAlias
    private var join = Join.full
    
    init(queryRequest: QueryRequest, selectedTable: DatabaseTableAlias, join: Join) {
        self.queryRequest = queryRequest
        self.selectedTable = selectedTable
        self.join = join
        var databases = DatabaseManager.sharedInstance.getDatabaseTables()
        if let databaseIndex = databases.index(where: { $0.databaseName == selectedTable.databaseName }),
            let table = selectedTable.toSelectedTable() {
            var removeTableNames = [selectedTable.tableName ?? ""]
            removeTableNames.append(contentsOf: table.relationships ?? [])
            for tableName in removeTableNames {
                if let tableIndex = databases[databaseIndex].tables.index(where: { $0 == tableName }) {
                    databases[databaseIndex].tables.remove(at: tableIndex)
                }
            }
            if let relationships = table.relationships, !relationships.isEmpty {
                databases.insert(DatabaseTables(databaseName: relationshipTitle, tables: relationships), at: 0)
            }
        } // remove table from its database
        super.init(list: databases)
    }
    
    override func actionAfterSelect(indexPath: IndexPath, alias: String?) {
        let database = list[indexPath.section]
        if let databaseName = database.databaseName, (indexPath.section == 0 && databaseName == relationshipTitle) {
            let joinTable = DatabaseTableAlias(databaseName: selectedTable.databaseName, tableName: database.tables[indexPath.row], alias: alias)
            let relationshipWith = selectedTable.toJoinByDatabaseAlias(join: join, with: joinTable, onConditions: nil)
            queryRequest?.addRelationship(with: relationshipWith)
            navigationController?.dismiss(animated: true, completion: nil)
        } // if let join relationships
    }
    
    override func getUniqueAliasName(input: String) -> String {
        return input
    }
}
