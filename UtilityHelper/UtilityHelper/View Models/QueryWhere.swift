//
//  QueryWhere.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 23/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class QueryWhere: QuerySelect {
    
    override func viewDidLoad(_ viewController: GenericTableViewController) {
        viewController.navigationItem.title = action.description
        addCloseOnLeftHandSide(viewController)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let queryRequest = queryRequest,
            let vc = GenericTableViewController.getViewController(viewModel: QueryWhereOperators(queryRequest: queryRequest, alias: list[indexPath.section].alias, property: list[indexPath.section].properties[indexPath.row])) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}