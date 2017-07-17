//
//  DatabaseTableListViewController.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 17/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class DatabaseTableListViewController: DatabaseTableViewController {

    var isQuery = false

    static func getViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "DatabaseViewer", bundle: Bundle(for: DatabaseTableListViewController.self))
        return storyboard.instantiateViewController(withIdentifier: "DatabaseTableListViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 60

        if !isQuery {
            navigationItem.title = "Database Viewer"
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close(_:)))
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Query", style: .plain, target: self, action: #selector(query(_:)))
        }
        else {
            navigationItem.title = "Select"
        }
    }

    dynamic private func close(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    dynamic private func query(_ sender: UIBarButtonItem) {
        if let vc = DatabaseTableListViewController.getViewController() as? DatabaseTableListViewController {
            vc.isQuery = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return DatabaseManager.sharedInstance.databaseNames.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let databaseName = DatabaseManager.sharedInstance.databaseNames[section]
        return DatabaseManager.sharedInstance.databases[databaseName]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DatabaseTableRowTableViewCell", for: indexPath)
        let databaseName = DatabaseManager.sharedInstance.databaseNames[indexPath.section]
        if let database = DatabaseManager.sharedInstance.databases[databaseName], database.count > indexPath.row {
            let table = database[indexPath.row]
            cell.textLabel?.text = table.name
            cell.detailTextLabel?.text = "\(table.count) item\(table.count == 1 ? "" : "s")"
        }
        cell.detailTextLabel?.textColor = UIColor.lightGray
        cell.accessoryType = isQuery ? .none : .detailDisclosureButton
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DatabaseManager.sharedInstance.databaseNames[section]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let databaseName = DatabaseManager.sharedInstance.databaseNames[indexPath.section]
        guard let tables = DatabaseManager.sharedInstance.databases[databaseName] else {
            return
        }

        let table = tables[indexPath.row]
        if isQuery, let vc = DatabaseQueryPropertiesTableViewController.getViewController(table: table) {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            let alert = UIAlertController(title: "Alias", message: "Set \(table.name) as:", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = table.alias
            })
            alert.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
                vc.table.customAlias = alert.textFields?.first?.text
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            navigationController?.present(alert, animated: true) { _ in tableView.deselectRow(at: indexPath, animated: true) }
        }
        else if let vc = DatabaseResultViewController.getViewController() {
            navigationController?.pushViewController(vc, animated: true)
            DispatchQueue.global().async {
                if let context = DatabaseManager.sharedInstance.contextDict[databaseName] {
                    vc.result = DisplayResult.prepare(title: table.propertiesName, contents: context.fetchAll(for: table.name, keys: table.propertiesName)) {
                        vc.prepareContentLayout()
                    } // prepare
                } // if let context
            } // async
        } // if let tables
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let tables = DatabaseManager.sharedInstance.databases[DatabaseManager.sharedInstance.databaseNames[indexPath.section]],
            let vc = DatabaseTableDetailsViewController.getViewController(table: tables[indexPath.row]) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
