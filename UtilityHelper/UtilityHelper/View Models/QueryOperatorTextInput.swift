//
//  QueryOperatorTextInput.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 24/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class QueryOperatorTextInput: NSObject, GenericTableViewModel {
    
    weak var navigationController: UINavigationController?
    private weak var queryRequest: QueryRequest?
    private var list = [String]()
    private let alias: String!
    private let property: Property!
    private let whereArgument: WhereArgument!
    
    init(queryRequest: QueryRequest, alias: String, property: Property, whereArgument: WhereArgument) {
        self.queryRequest = queryRequest
        self.alias = alias
        self.property = property
        self.whereArgument = whereArgument
        if let databaseTable = queryRequest.getDatabaseTableAlias(from: alias) {
            self.list = DatabaseManager.sharedInstance.contextDict[databaseTable.databaseName]?.fetchValuesIn(for: databaseTable.tableName, key: property.name) ?? []
        }
    }
    
    func viewDidLoad(_ viewController: GenericTableViewController) {
        viewController.navigationItem.title = whereArgument.description
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0, let textFieldCell = getTextFieldCell(from: tableView, indexPath: indexPath) {
            return textFieldCell
        }
        let cell = getCell(from: tableView, indexPath: indexPath)
        cell.textLabel?.text = list[indexPath.row].description
        cell.detailTextLabel?.text = nil
        cell.accessoryType = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            // TODO
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Value" : nil
    }
}
