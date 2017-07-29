//
//  QuerySelect.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 21/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class QuerySelect: NSObject, GenericTableViewModel {
    
    weak var navigationController: UINavigationController?
    internal var list = [DatabaseAliasTableWithProperties]()
    internal weak var queryRequest: QueryRequest?
    internal var selectedIndexPath = [IndexPath]()
    internal var action = QueryAction.default
    
    init(queryRequest: QueryRequest) {
        self.queryRequest = queryRequest
    }
    
    convenience init(queryRequest: QueryRequest, action: QueryAction) {
        self.init(queryRequest: queryRequest)
        self.action = action
        self.list = queryRequest.getSelectableDatabaseAliasTableWithProperties(includeWildCard: action == .select)
    }
    
    func viewDidLoad(_ viewController: GenericTableViewController) {
        viewController.navigationItem.title = action.description
        addCloseOnLeftHandSide(viewController)
        addDoneOnRightHandSide(viewController)
    }
    
    func doneIsClicked() {
        var properties = [AliasProperty]()
        for indexPath in selectedIndexPath {
            let table = list[indexPath.section]
            let name = table.properties[indexPath.row].name
            properties.append(AliasProperty(alias: table.alias, propertyName: name))
        }

        switch action {
        case .select:   queryRequest?.selected.append(contentsOf: properties)
        case .groupBy:  queryRequest?.groupBy.append(contentsOf: properties)
        case .having:   queryRequest?.having.append(contentsOf: properties)
        default:
            break
        }
        queryRequest?.reload()
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].properties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(from: tableView, indexPath: indexPath)
        cell.textLabel?.text = list[indexPath.section].properties[indexPath.row].name
        cell.selectionStyle = .default
        cell.accessoryType = selectedIndexPath.contains(indexPath) ? .checkmark : .none
        cell.detailTextLabel?.text = nil
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return list[section].description
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let index = selectedIndexPath.index(of: indexPath) {
            selectedIndexPath.remove(at: index)
            cell?.accessoryType = .none
        }
        else {
            selectedIndexPath.append(indexPath)
            cell?.accessoryType = .checkmark
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        applyHeaderLayout(view: view)
    }
}
