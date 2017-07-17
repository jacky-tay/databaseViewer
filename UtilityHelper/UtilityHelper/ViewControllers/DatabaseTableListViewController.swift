//
//  DatabaseTableListViewController.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 17/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class DatabaseTableListViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.groupTableViewBackground
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60
        navigationItem.title = "Database Viewer"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close(_:)))
    }

    dynamic private func close(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
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
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DatabaseManager.sharedInstance.databaseNames[section]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let databaseName = DatabaseManager.sharedInstance.databaseNames[indexPath.section]
        if let tables = DatabaseManager.sharedInstance.databases[databaseName],
            let vc = DatabaseResultViewController.getViewController() {

            navigationController?.pushViewController(vc, animated: true)

            DispatchQueue.global().async {
                let table = tables[indexPath.row]
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
