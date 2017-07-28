//
//  QueryHaving.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 28/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class QueryHaving: NSObject, GenericTableViewModel {
    weak var navigationController: UINavigationController?
    private weak var queryRequest: QueryRequest?
    
    let list: [Aggregate] = [.average, .count, .maximum, .minimum, .sum]
    
    init(queryRequest: QueryRequest) {
        self.queryRequest = queryRequest
    }
    
    func viewDidLoad(_ viewController: GenericTableViewController) {
        viewController.navigationItem.title = "Having"
        addCloseOnLeftHandSide(viewController)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(from: tableView, indexPath: indexPath)
        cell.textLabel?.text = list[indexPath.row].description
        cell.detailTextLabel?.text = nil
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let queryRequest = queryRequest,
            let vc = GenericTableViewController.getViewController(viewModel: QueryHavingSelect(queryRequest: queryRequest, aggregate: list[indexPath.row])) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
