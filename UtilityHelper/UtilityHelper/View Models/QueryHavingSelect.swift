//
//  QueryHavingSelect.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 28/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class QueryHavingSelect: QuerySelect {
    
    var aggregate: Aggregate!
    
    convenience init(queryRequest: QueryRequest, aggregate: Aggregate) {
        self.init(queryRequest: queryRequest, action: .having)
        self.aggregate = aggregate
    }
    
    override func viewDidLoad(_ viewController: GenericTableViewController) {
        viewController.navigationItem.title = aggregate.description
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let table = list[indexPath.section]
        let property = table.properties[indexPath.row]
        if let queryRequest = queryRequest,
            let vc = GenericTableViewController.getViewController(viewModel: QueryComparator(queryRequest: queryRequest, action: .having, aliasProperty: AliasProperty(alias: table.alias, propertyName: property.name), category: property.attributeType.getCategory())) {
                navigationController?.pushViewController(vc, animated: true)
        }
    }
}
