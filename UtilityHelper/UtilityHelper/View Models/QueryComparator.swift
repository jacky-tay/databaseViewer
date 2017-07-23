//
//  QueryComparator.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 22/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class QueryComparator: NSObject, GenericTableViewModel {
    weak var navigationController: UINavigationController?
    private weak var queryRequest: QueryRequest?
    private let list: [Comparator]!
    private let action: QueryAction!
    internal var sectionTitle: String?
    
    init(queryRequest: QueryRequest, action: QueryAction, filterBy category: AttributedCategory?) {
        self.queryRequest = queryRequest
        self.list = Comparator.getAll(filterBy: category)
        self.action = action
    }
    
    func viewDidLoad(_ viewController: GenericTableViewController) {
        viewController.navigationItem.title = "Select"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(from: tableView, indexPath: indexPath)
        cell.textLabel?.text = list[indexPath.row].rawValue
        cell.detailTextLabel?.text = nil
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let comparator = list[indexPath.row]
        if action == .join, let queryRequest = queryRequest, let vc = GenericTableViewController.getViewController(viewModel: QueryJoinRequestTablePropertySelect(queryRequest: queryRequest)) {
            queryRequest.joins.last?.onConditions?.last?.comparator = comparator
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle
    }
}
