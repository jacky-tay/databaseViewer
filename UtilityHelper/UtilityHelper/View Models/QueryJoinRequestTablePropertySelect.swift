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
    private let createNewOnConditions: Bool
    
    override init(queryRequest: QueryRequest) {
        
        self.createNewOnConditions = (queryRequest.joins.last?.onConditions?.isEmpty ?? false) ||
            queryRequest.joins.last?.onConditions?.last?.propertyName != nil
        
        super.init(queryRequest: queryRequest)
        self.action = .join

        // insert otherPropertyName first, then propertyName
        if createNewOnConditions, let properties = queryRequest.joins.last?.otherTable.toSelectedTable()?.toDatabaseTableAliasWithProperties(includeWildCard: false) {
            self.list = [properties]
            queryRequest.joins.last?.onConditions?.append(JoinWithDatabaseTableAlias())
        }
        else if let properties = queryRequest.joins.last?.toSelectedTable()?.toDatabaseTableAliasWithProperties(includeWildCard: false) {
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
        let property = list[indexPath.section].properties[indexPath.row]
        if createNewOnConditions,
            let queryRequest = queryRequest,
            let vc = GenericTableViewController.getViewController(viewModel: QueryComparator(queryRequest: queryRequest, action: .join, aliasProperty: AliasProperty(alias: queryRequest.joins.last?.otherTable?.alias, propertyName: property.name), category: property.attributeType.getCategory())) {
            let lastJoin = queryRequest.joins.last
            lastJoin?.onConditions?.last?.otherTableProperty = property.name
            //(vc.viewModel as? QueryComparator)?.sectionTitle = ".".joined(contentsOf: [lastJoin?.otherTable?.alias, property.name])
            navigationController?.pushViewController(vc, animated: true)
        }
        else if let queryRequest = queryRequest,
            let vc = GenericTableViewController.getViewController(viewModel: QueryJoinOnConditions(queryRequest: queryRequest)) {
            queryRequest.joins.last?.onConditions?.last?.propertyName = property.name
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
