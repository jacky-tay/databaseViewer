//
//  DatabaseTableJoinSelect.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 22/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class DatabaseTableJoinSelect: DatabaseTableSelect {
    
    private weak var queryRequest: QueryRequest?
    private let selectedTable: DatabaseTableAlias
    private var join = Join.full
    private var hasRelationshipSection = false
    
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
                databases.insert(DatabaseTables(databaseName: "Relationships", tables: relationships), at: 0)
            }
        } // remove table from its database
        super.init(list: databases)
    }
    
    override func viewDidLoad(_ viewController: GenericTableViewController) {
        viewController.navigationItem.title = join.description
    }
    
    func viewWillAppear(_ viewController: GenericTableViewController) {
        // pop
        if !viewController.isMovingToParentViewController, let count = queryRequest?.joins.count {
            queryRequest?.joins.remove(at: count - 1)
        }
    }
    
    override func actionAfterSelect(indexPath: IndexPath, alias: String, cell: UITableViewCell?) {
        let database = list[indexPath.section]
        
        if indexPath.section == 0 && hasRelationshipSection {
            let joinTable = DatabaseTableAlias(databaseName: selectedTable.databaseName, tableName: database.tables[indexPath.row], alias: alias)
            let relationshipWith = selectedTable.toJoinByDatabaseAlias(join: join, with: joinTable, onConditions: nil)
            queryRequest?.addRelationship(with: relationshipWith)
            navigationController?.dismiss(animated: true, completion: nil)
        } // if let join relationships
        else if let queryRequest = queryRequest {
            cell?.accessoryType = .disclosureIndicator
            let joinTable = DatabaseTableAlias(databaseName: database.databaseName, tableName: database.tables[indexPath.row], alias: alias)
            let relationshipWith = selectedTable.toJoinByDatabaseAlias(join: join, with: joinTable, onConditions: [])
            queryRequest.addRelationship(with: relationshipWith)
            if let vc = GenericTableViewController.getViewController(viewModel: QueryJoinRequestTablePropertySelect(queryRequest: queryRequest)) {
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func getUniqueAliasName(input: String) -> String {
        return input
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.accessoryType = hasRelationshipSection && indexPath.section == 0 ? .none : .disclosureIndicator
        return cell
    }
}
