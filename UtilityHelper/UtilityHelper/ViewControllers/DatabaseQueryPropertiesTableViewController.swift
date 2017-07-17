//
//  DatabaseQueryPropertiesTableViewController.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 18/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class DatabaseQueryPropertiesTableViewController: DatabaseTableViewController, QueryActionDelegate {

    internal var table: Table!
    private var selected = [IndexPath]()

    static func getViewController(table: Table) -> DatabaseQueryPropertiesTableViewController? {
        let storyboard = UIStoryboard(name: "DatabaseViewer", bundle: Bundle(for: DatabaseQueryPropertiesTableViewController.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "DatabaseQueryPropertiesTableViewController") as? DatabaseQueryPropertiesTableViewController
        vc?.table = table
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = table.alias
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: QueryAction.execute.rawValue, style: .plain, target: self, action: #selector(barButtonItemDidClicked(sender:)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
        setToolbar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }

    // MARK: - 
    private func setToolbar() {
        let items: [QueryAction] = [.select, .join, .where, .orderBy, .groupBy]
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = items.enumerated().flatMap { enumerate -> [UIBarButtonItem] in
            let item = UIBarButtonItem(title: enumerate.element.rawValue, style: .plain, target: self, action: #selector(barButtonItemDidClicked(sender:)))
            return enumerate.offset + 1 < items.count ? [item, space] : [item]
        }
    }

    // MARK: - Actions
    dynamic private func barButtonItemDidClicked(sender: UIBarButtonItem) {
        guard let action = QueryAction(rawValue: sender.title ?? "") else {
            return
        }
        switch action {
        case .join:
            showJoinOptions()
        case .execute:
            break
        default:
            if let vc = DatabaseTableDetailsViewController.getViewController(tables: [table], action: action, delegate: self) {
                navigationController?.presentViewControllerModally(vc)
            }
        }
    }

    private func showJoinOptions() {
        let alert = UIAlertController(title: "Join", message: nil, preferredStyle: .actionSheet)
        for join in Join.getAllJoins() {
            alert.addAction(UIAlertAction(title: "\(join) join".capitalized, style: .default) { [weak self] (action) in
                self?.didSelectedJoin(sender: action)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        navigationController?.present(alert, animated: true, completion: nil)
    }

    private func didSelectedJoin(sender: UIAlertAction) {
        // TODO
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return table.propertiesName.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DatabaseTableRowTableViewCell", for: indexPath)
        cell.textLabel?.text = table.propertiesName[indexPath.row]
        cell.accessoryType = selected.contains(indexPath) ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return table.name
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if selected.contains(indexPath), let index = selected.index(of: indexPath) {
            selected.remove(at: index)
            cell?.accessoryType = .none
        }
        else {
            selected.append(indexPath)
            cell?.accessoryType = .checkmark
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - QueryActionDelegate
    func didSelect(properties: [(TablePropertyPair)]) {

    }

    func didOrderBy(properties: [(TablePropertyPair)]) {

    }

    func didGroupBy(properties: [(TablePropertyPair)]) {

    }
}
