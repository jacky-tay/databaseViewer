//
//  DatabaseTableSelect.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 22/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class DatabaseTableSelect: NSObject, GenericTableViewModel {
    
    weak var navigationController: UINavigationController?
    let list: [DatabaseTables]!
    
    init(list: [DatabaseTables]) {
        self.list = list
    }
    
    func viewDidLoad(_ viewController: GenericTableViewController) {
        viewController.navigationItem.title = "Select"
    }
    
    func actionAfterSelect(indexPath: IndexPath, alias: String, cell: UITableViewCell?) {
        if let table = DatabaseManager.sharedInstance.getTableFrom(databaseName: list[indexPath.section].databaseName, tableName: list[indexPath.section].tables[indexPath.row]),
            let vc = GenericTableViewController.getViewController(viewModel: QueryRequest(from: table.toSelectedTable(alias: alias))) {
            (vc.viewModel as? QueryRequest)?.delegate = vc
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func getUniqueAliasName(input: String) -> String {
        return input
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
        cell.textLabel?.text = list[indexPath.section].tables[indexPath.row]
        cell.detailTextLabel?.text = nil
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tableName = list[indexPath.section].tables[indexPath.row]
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        let alert = UIAlertController(title: "Alias", message: "Set \(tableName) as:", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { [weak self] (textField) in
            textField.text = self?.getUniqueAliasName(input: tableName.takeUppercasedCharacter())
        })
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            if let alias = alert.textFields?.first?.text {
                self?.actionAfterSelect(indexPath: indexPath, alias: alias, cell: tableView.cellForRow(at: indexPath))
            }
        })
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return list[section].databaseName
    }
}
