//
//  JoinQueryRequestWithTableOptions.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 21/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class JoinQueryRequestWithTableOptions: NSObject, GenericTableViewModel {
    
    weak var navigationController: UINavigationController?
    private weak var queryRequest: QueryRequest?
    private let databaseTableAliases: [DatabaseTableAlias]!
    
    init(queryRequest: QueryRequest) {
        self.queryRequest = queryRequest
        self.databaseTableAliases = queryRequest.getSelectableDatabaseTableAlias()
    }
    
    func viewDidLoad(_ viewController: GenericTableViewController) {
        viewController.navigationItem.title = "Select"
        addCloseOnLeftHandSide(viewController)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return databaseTableAliases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(from: tableView, indexPath: indexPath)
        cell.textLabel?.text = databaseTableAliases[indexPath.row].tableName
        cell.accessoryType = .disclosureIndicator
        cell.detailTextLabel?.text = nil
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let queryRequest = queryRequest,
            let vc = GenericTableViewController.getViewController(viewModel: JoinQueryRequest(databaseTableAlias: databaseTableAliases[indexPath.row], queryRequest: queryRequest)) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Table to Join"
    }
}
