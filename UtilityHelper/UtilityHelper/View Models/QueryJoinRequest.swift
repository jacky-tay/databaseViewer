//
//  QueryJoinRequest.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 21/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class QueryJoinRequest: NSObject, GenericTableViewModel {
    
    weak var navigationController: UINavigationController?
    private let databaseAliasTable: DatabaseAliasTable!
    private weak var queryRequest: QueryRequest?
    private let joinTypes = Join.getAllJoins()
    
    init(databaseAliasTable: DatabaseAliasTable, queryRequest: QueryRequest) {
        self.databaseAliasTable = databaseAliasTable
        self.queryRequest = queryRequest
    }
    
    func viewDidLoad(_ viewController: GenericTableViewController) {
        viewController.navigationItem.title = "Join With"
        addCloseOnLeftHandSide(viewController)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return joinTypes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(from: tableView, indexPath: indexPath)
        cell.textLabel?.text = joinTypes[indexPath.row].description
        cell.accessoryType = .disclosureIndicator
        cell.detailTextLabel?.text = nil
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return databaseAliasTable.description
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let queryRequest = queryRequest,
            let vc = GenericTableViewController.getViewController(viewModel: DatabaseTableJoinSelect(queryRequest: queryRequest, aliasTable: databaseAliasTable, join: joinTypes[indexPath.row])) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        applyHeaderLayout(view: view)
    }
}
