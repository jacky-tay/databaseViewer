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
            // TODO: check
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
        // TODO
//        if queryRequest?.joins.last?.onConditions?.last?.comparator == nil,
//            let count = queryRequest?.joins.last?.onConditions?.count, count > 0 {
//            // prevent user tap add another and then pop back
//            queryRequest?.joins.last?.onConditions?.remove(at: count - 1)
//        }
        
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    func viewWillDisappeared(_ viewController: GenericTableViewController) {
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    dynamic private func addCondition(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let options: [WhereCategory] = [.and, .or]
        options.forEach { (option) in
            alert.addAction(UIAlertAction(title: option.description, style: .default) { [weak self] _ in
                self?.navigate(withOption: option)
            })
        } // forEach
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    private func navigate(withOption: WhereCategory) {
        if let queryRequest = queryRequest,
            let vc = GenericTableViewController.getViewController(viewModel: QueryJoinRequestTablePropertySelect(queryRequest: queryRequest, joinedAliasProperty: nil, comparator: nil)) {
            if withOption == .and {
                queryRequest.joins.last?.insert(clause: .add([]))
            }
            else {
                queryRequest.joins.last?.insert(clause: .or([]))
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queryRequest?.joins.last?.onConditions?.getCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getWhereClauseTableViewCell(from: tableView, indexPath: indexPath)
        if let cell = cell as? WhereClauseTableViewCell, let clause = queryRequest?.joins.last?.onConditions?.getDescription(row: indexPath.row) {
            cell.updateContent(statement: clause)
        }
        cell.accessoryType = .none
        cell.selectionStyle = .none
        return cell
    }
}
