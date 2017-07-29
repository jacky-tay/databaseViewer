//
//  DatabaseTableView.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 22/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class DatabaseTableView: NSObject, GenericTableViewModel {
    
    weak var navigationController: UINavigationController?
    var list = [DatabaseTablesWithCount]()
    
    func viewDidLoad(_ viewController: GenericTableViewController) {
        addCloseOnLeftHandSide(viewController)
        viewController.tableView.rowHeight = 60
        viewController.navigationItem.title = "Database Viewer"
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Query", style: .plain, target: self, action: #selector(query(sender:)))
        list = DatabaseManager.sharedInstance.getDatabaseTablesWithCount()
    }
    
    func viewWillAppear(_ viewController: GenericTableViewController) {

    }
    
    private dynamic func query(sender: UIBarButtonItem) {
        let displayList = DatabaseManager.sharedInstance.getDatabaseTables()
        if let vc = GenericTableViewController.getViewController(viewModel: DatabaseTableSelect(list: displayList)) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].tables.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(from: tableView, indexPath: indexPath)
        cell.accessoryType = .detailDisclosureButton
        cell.selectionStyle = .default
        cell.textLabel?.text = list[indexPath.section].tables[indexPath.row].name
        cell.detailTextLabel?.text = "\(list[indexPath.section].tables[indexPath.row].count) items"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let database = list[indexPath.section]
        let tableName = database.tables[indexPath.row].name
        if let vc = DatabaseResultViewController.getViewController(),
            let databaseName = database.databaseName,
            let table = DatabaseManager.sharedInstance.getTableFrom(databaseName: databaseName, tableName: tableName) {
            let properties = table.properties.flatMap { $0.name }
            
            DispatchQueue.global().async {
                if let context = DatabaseManager.sharedInstance.contextDict[databaseName] {
                    vc.result = DisplayResult.prepare(titles: properties, contents: context.fetchAll(for: tableName, keys: properties)) {
                        vc.prepareContentLayout()
                    } // prepare
                } // if let context
            } // async
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let database = list[indexPath.section]
        if let table = DatabaseManager.sharedInstance.getTable(from: DatabaseTable(databaseName: database.databaseName, tableName: database.tables[indexPath.row].name)),
            let vc = GenericTableViewController.getViewController(viewModel: PropertyRelationship(databaseTable: table.toDatabaseAliasTableWithPropertiesRelationships())) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return list[section].databaseName
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "\(list[section].tables.count) tables"
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        applyFooterLayout(view: view)
    }
}

