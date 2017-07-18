//
//  DatabaseTableListViewController.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 17/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class DatabaseTableListViewController: DatabaseTableViewController {

    private var action = QueryAction.default
    private var joinType: Join?
    private var databases: [DatabaseTableLitePair] = []

    static func getViewController() -> DatabaseTableListViewController? {
        let storyboard = UIStoryboard(name: "DatabaseViewer", bundle: Bundle(for: DatabaseTableListViewController.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "DatabaseTableListViewController") as? DatabaseTableListViewController
        vc?.databases = DatabaseManager.sharedInstance.getDatabaseTableLitePairs()
        return vc
    }

    static func getViewController(joinType: Join, with table: Table) -> DatabaseTableListViewController? {
        let vc = getViewController()
        vc?.action = .join
        vc?.joinType = joinType

        if let databaseIndex = vc?.databases.index(where: { $0.databaseName == table.databaseName }) {
            var toRemove = [table.name]
            let relationships = table.relationships ?? []
            toRemove.append(contentsOf: relationships)
            for value in toRemove {
                if let index = vc?.databases[databaseIndex].tables.index(where: { $0.name == value }) {
                    vc?.databases[databaseIndex].tables.remove(at: index)
                }
            }
            if !relationships.isEmpty {
                vc?.databases.insert(("Relationships", relationships.map { ($0, 0) }), at: 0)
            }
        }
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = action == .join ? 44 : 60

        if action == .default {
            navigationItem.title = "Database Viewer"
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Query", style: .plain, target: self, action: #selector(query(_:)))
        }
        else {
            navigationItem.title = joinType?.description ?? action.description
        }
        navigationItem.leftBarButtonItem = action == .select ? nil : UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close(_:)))
    }

    dynamic private func close(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    dynamic private func query(_ sender: UIBarButtonItem) {
        if let vc = DatabaseTableListViewController.getViewController() {
            vc.action = .select
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return databases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return databases[section].tables.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DatabaseTableRowTableViewCell", for: indexPath)
        let database = databases[indexPath.section]
        if database.tables.count > indexPath.row {
            let table = database.tables[indexPath.row]
            cell.textLabel?.text = table.name
            cell.detailTextLabel?.text = action == .join ? nil : "\(table.count) item\(table.count == 1 ? "" : "s")"
        }
        cell.detailTextLabel?.textColor = UIColor.lightGray
        cell.accessoryType = action != .default ? .none : .detailDisclosureButton
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return databases[section].databaseName
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let databaseName = databases[indexPath.section].databaseName
        let tableName = databases[indexPath.section].tables[indexPath.row].name
        guard let table = DatabaseManager.sharedInstance.getTableFrom(databaseName: databaseName, tableName: tableName) else {
            return
        }

        if action == .select, let vc = DatabaseQueryPropertiesTableViewController.getViewController(table: table) {
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
            let databaseName = databases[indexPath.section].databaseName
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
        let databaseName = databases[indexPath.section].databaseName
        let tableName = databases[indexPath.section].tables[indexPath.row].name
        guard let table = DatabaseManager.sharedInstance.getTableFrom(databaseName: databaseName, tableName: tableName) else {
            return
        }

        if let vc = DatabaseTableDetailsViewController.getViewController(table: table) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
