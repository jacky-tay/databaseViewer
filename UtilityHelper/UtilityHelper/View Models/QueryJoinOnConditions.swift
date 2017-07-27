//
//  QueryJoinOnConditions.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 22/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class QueryJoinOnConditions: NSObject, GenericTableViewModel {
    weak var navigationController: UINavigationController?
    private weak var queryRequest: QueryRequest?
    
    init(queryRequest: QueryRequest) {
        self.queryRequest = queryRequest
    }
    
    func viewDidLoad(_ viewController: GenericTableViewController) {
        viewController.navigationItem.title = queryRequest?.joins.last?.joinType.description
        addDoneOnRightHandSide(viewController)
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        viewController.toolbarItems = [space,
                                       UIBarButtonItem(title: "Add another condition", style: .plain, target: self, action: #selector(addCondition(sender:))),
                                       space]
        
        if let genericTableViewControllers = viewController.navigationController?.viewControllers as? [GenericTableViewController] {
            for vc in genericTableViewControllers where
                (vc.viewModel is QueryJoinRequestTablePropertySelect || vc.viewModel is QueryComparator) {
                    vc.removeFromParentViewController()
            }
        }
    }
    
    func doneIsClicked() {
        queryRequest?.reload()
    }
    
    func viewWillAppear(_ viewController: GenericTableViewController) {
        if queryRequest?.joins.last?.onConditions?.last?.comparator == nil,
            let count = queryRequest?.joins.last?.onConditions?.count, count > 0 {
            // prevent user tap add another and then pop back
            queryRequest?.joins.last?.onConditions?.remove(at: count - 1)
        }
        
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    func viewWillDisappeared(_ viewController: GenericTableViewController) {
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    dynamic private func addCondition(sender: UIBarButtonItem) {
        if let queryRequest = queryRequest,
            let vc = GenericTableViewController.getViewController(viewModel: QueryJoinRequestTablePropertySelect(queryRequest: queryRequest)) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queryRequest?.joins.last?.onConditions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(from: tableView, indexPath: indexPath)
        cell.textLabel?.text = queryRequest?.joins.last?.getConditionDescription(at: indexPath.row)
        cell.detailTextLabel?.text = nil
        cell.accessoryType = .none
        cell.selectionStyle = .none
        return cell
    }
}
