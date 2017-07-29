//
//  QueryJoinRequestWithTableOptions.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 21/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class QueryJoinRequestWithTableOptions: NSObject, GenericTableViewModel {
    
    weak var navigationController: UINavigationController?
    private weak var queryRequest: QueryRequest?
    private let databaseAliasTables: [DatabaseAliasTable]!
    
    init(queryRequest: QueryRequest) {
        self.queryRequest = queryRequest
        self.databaseAliasTables = queryRequest.getSelectableDatabaseAliasTables()
    }
    
    func viewDidLoad(_ viewController: GenericTableViewController) {
        viewController.navigationItem.title = "Select"
        addCloseOnLeftHandSide(viewController)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return databaseAliasTables.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(from: tableView, indexPath: indexPath)
        cell.textLabel?.text = databaseAliasTables[indexPath.row].tableName
        cell.accessoryType = .disclosureIndicator
        cell.detailTextLabel?.text = nil
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let queryRequest = queryRequest,
            let vc = GenericTableViewController.getViewController(viewModel: QueryJoinRequest(databaseAliasTable: databaseAliasTables[indexPath.row], queryRequest: queryRequest)) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Table to Join"
    }
}
