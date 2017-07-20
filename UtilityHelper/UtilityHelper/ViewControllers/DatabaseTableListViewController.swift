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
    private var relationshipWith: DatabaseTableAlias?
    private let relationships = "Relationships"
    private weak var delegate: QueryActionDelegate?

    static func getViewController() -> DatabaseTableListViewController? {
        let storyboard = UIStoryboard(name: "DatabaseViewer", bundle: Bundle(for: DatabaseTableListViewController.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "DatabaseTableListViewController") as? DatabaseTableListViewController
        vc?.databases = DatabaseManager.sharedInstance.getDatabaseTableLitePairs()
        return vc
    }

    static func getViewController(joinType: Join, with table: SelectedTable, delegate: QueryActionDelegate) -> DatabaseTableListViewController? {
        let vc = getViewController()
        vc?.action = .join
        vc?.joinType = joinType
        vc?.relationshipWith = table.toDatabaseTableAlias()
        vc?.delegate = delegate
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
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return action == .default ? "\(databases[section].tables.count) tables" : nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let databaseName = databases[indexPath.section].databaseName
        let tableName = databases[indexPath.section].tables[indexPath.row].name
        guard let table = DatabaseManager.sharedInstance.getTableFrom(databaseName: databaseName, tableName: tableName) ??
            DatabaseManager.sharedInstance.getTableFrom(databaseName: relationshipWith?.databaseName, tableName: tableName) else {
            return
        }

        if action != .default {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            let alert = UIAlertController(title: "Alias", message: "Set \(table.name) as:", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = table.name.takeUppercasedCharacter()
            })
            alert.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
                if self?.action == .select, let vc = DatabaseQueryTableViewController.getViewController(table: table.toSelectedTable(alias: alert.textFields?.first?.text)) {
                    
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                else if self?.action == .join,
                    let joinType = self?.joinType,
                    let relationshipWith = self?.relationshipWith?.toJoinByDatabaseAlias(join: joinType, with: table.toDatabaseTable(alias: alert.textFields?.first?.text), onConditions: nil) {
                    
                    self?.delegate?.addRelationship(with: relationshipWith)
                    self?.navigationController?.dismiss(animated: true, completion: nil)
                }
                else if self?.action == .join, let relationshipWith = self?.relationshipWith, let joinType = self?.joinType {
                    // push
                }
            })
            navigationController?.present(alert, animated: true) { _ in tableView.deselectRow(at: indexPath, animated: true) }
        }
        else if action == .default, let vc = DatabaseResultViewController.getViewController() {
            navigationController?.pushViewController(vc, animated: true)
            let databaseName = databases[indexPath.section].databaseName
            DispatchQueue.global().async {
                if let context = DatabaseManager.sharedInstance.contextDict[databaseName] {
                    vc.result = DisplayResult.prepare(titles: table.properties.map { $0.name }, contents: context.fetchAll(for: table.name, keys: table.properties.map { $0.name })) {
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
