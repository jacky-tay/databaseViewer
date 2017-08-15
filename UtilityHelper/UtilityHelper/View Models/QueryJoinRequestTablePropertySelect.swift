//
//  QueryJoinRequestTablePropertySelect.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 22/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class QueryJoinRequestTablePropertySelect: QuerySelect {
    
    private var hasComparator = false
    private var joinedAliasProperty: AliasProperty?
    private var comparator: Comparator?
    
    init(queryRequest: QueryRequest, joinedAliasProperty: AliasProperty?, comparator: Comparator?) {
        
        super.init(queryRequest: queryRequest)
        self.action = .join
        self.joinedAliasProperty = joinedAliasProperty
        self.comparator = comparator

        // insert otherPropertyName first, then propertyName
        if joinedAliasProperty == nil, let properties = queryRequest.joins.last?.otherTable.toAliasTable()?.toDatabaseAliasTableWithProperties(includeWildCard: false) {
            self.list = [properties]
        }
        else if let properties = queryRequest.joins.last?.toAliasTable()?.toDatabaseAliasTableWithProperties(includeWildCard: false, with: queryRequest.getProperty(from: joinedAliasProperty)?.attributeType.getCategory()) {
            self.list = [properties]
        }
    }
    
    override func viewDidLoad(_ viewController: GenericTableViewController) {
        viewController.navigationItem.title = "On"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath.forEach { tableView.cellForRow(at: $0)?.accessoryType = .none }
        selectedIndexPath.removeAll()
        
        super.tableView(tableView, didSelectRowAt: indexPath)
        let table = list[indexPath.section]
        let property = table.properties[indexPath.row]
        let aliasProperty = AliasProperty(alias: table.alias, propertyName: property.name)
        
        if joinedAliasProperty == nil,
            let queryRequest = queryRequest,
            let vc = GenericTableViewController.getViewController(viewModel: QueryComparator(queryRequest: queryRequest, action: .join, aliasProperty: aliasProperty, category: property.attributeType.getCategory())) {
            
            navigationController?.pushViewController(vc, animated: true)
        }
        else if let queryRequest = queryRequest,
            let joinedAliasProperty = joinedAliasProperty,
            let comparator = comparator,
            let vc = GenericTableViewController.getViewController(viewModel: QueryJoinOnConditions(queryRequest: queryRequest)) {
            let statement = Statement(aliasProperty: joinedAliasProperty, argument: comparator, otherAliasProperty: aliasProperty)
            queryRequest.joins.last?.insert(clause: .base(statement))
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
