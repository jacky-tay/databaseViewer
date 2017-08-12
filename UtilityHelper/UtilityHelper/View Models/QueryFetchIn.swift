//
//  QueryFetchIn.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 23/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class QueryFetchIn: NSObject, GenericTableViewModel {
    weak var navigationController: UINavigationController?
    private weak var queryRequest: QueryRequest?
    private var list = [String]()
    private var selectedIndexPath = [IndexPath]()
    private let aliasProperty: AliasProperty!
    
    init(queryRequest: QueryRequest, aliasProperty: AliasProperty) {
        self.queryRequest = queryRequest
        self.aliasProperty = aliasProperty
        if let alias = aliasProperty.alias,
            let propertyName = aliasProperty.propertyName,
            let databaseTable = queryRequest.getDatabaseAliasTable(from: alias) {
            self.list = DatabaseManager.sharedInstance.contextDict[databaseTable.databaseName]?.fetchValuesIn(for: databaseTable.tableName, key: propertyName) ?? []
        }
    }
    
    func viewDidLoad(_ viewController: GenericTableViewController) {
        viewController.navigationItem.title = "IN"
        addDoneOnRightHandSide(viewController)
    }
    
    func doneIsClicked() {
        let options = selectedIndexPath.flatMap { [weak self] in self?.list[$0.row] }
        if !options.isEmpty {
            let statement = Statement(aliasProperty: aliasProperty, argument: Argument.in, values: options)
            queryRequest?.insert(statement: statement)
            queryRequest?.reload()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(from: tableView, indexPath: indexPath)
        cell.textLabel?.text = list[indexPath.row].description
        cell.detailTextLabel?.text = nil
        cell.accessoryType = selectedIndexPath.contains(indexPath) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let index = selectedIndexPath.index(where: { $0 == indexPath }) {
            selectedIndexPath.remove(at: index)
            cell?.accessoryType = .none
        }
        else {
            selectedIndexPath.append(indexPath)
            cell?.accessoryType = .checkmark
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
