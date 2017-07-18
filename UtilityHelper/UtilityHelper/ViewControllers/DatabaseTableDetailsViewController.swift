//
//  DatabaseTableDetailsViewController.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 17/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class DatabaseTableDetailsViewController: DatabaseTableViewController {

    private var tables: [Table]!
    private var action = QueryAction.default
    private var selectedIndexPath = [IndexPath]()
    private weak var delegate: QueryActionDelegate?

    class func getViewController(table: Table) -> DatabaseTableDetailsViewController? {
        let storyboard = UIStoryboard(name: "DatabaseViewer", bundle: Bundle(for: DatabaseTableDetailsViewController.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "DatabaseTableDetailsViewController") as? DatabaseTableDetailsViewController
        vc?.tables = [table]
        return vc
    }

    class func getViewController(tables: [Table], action: QueryAction, delegate: QueryActionDelegate?) -> DatabaseTableDetailsViewController? {
        let storyboard = UIStoryboard(name: "DatabaseViewer", bundle: Bundle(for: DatabaseTableDetailsViewController.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "DatabaseTableDetailsViewController") as? DatabaseTableDetailsViewController
        vc?.tables = tables
        vc?.action = action
        vc?.delegate = delegate
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = action == .default ? tables.first?.name : action.description
        if action != .default {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done(_:)))
        }
        view.backgroundColor = UIColor.groupTableViewBackground
        tableView.tableFooterView = UIView()
    }

    private dynamic func done(_ sender: AnyObject) {
        let properties = selectedIndexPath.flatMap { [weak self] indexPath -> TablePropertyPair? in
            if let table = self?.tables[indexPath.section] {
                return (table.databaseName, table.name, table.propertiesName[indexPath.row] )
            }
            return nil
        }
        
        switch action {
        case .select:   delegate?.didSelect(properties: properties)
        case .orderBy:  delegate?.didOrderBy(properties: properties)
        case .groupBy:  delegate?.didGroupBy(properties: properties)
        default:    break
        }

        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return action == .default ? ((tables.first?.relationships?.isEmpty ?? true) ? 1 : 2) :
            tables.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return action == .default ? (section == 0 ? tables[section].propertiesName.count : tables[section].relationships?.count ?? 0) :
            tables[section].propertiesName.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DatabaseTableRowTableViewCell", for: indexPath)
        if action == .default {
            cell.selectionStyle = .none
            cell.accessoryType = .none
            let table = tables[0]
            if indexPath.section == 0, let property = table.properties[table.propertiesName[indexPath.row]] {
                cell.textLabel?.text = table.propertiesName[indexPath.row]
                cell.detailTextLabel?.text = property.description
            }
            else if indexPath.section == 1, let relationships = table.relationships {
                cell.textLabel?.text = relationships[indexPath.row]
                cell.detailTextLabel?.text = nil
            }
            cell.detailTextLabel?.textColor = UIColor.lightGray
        }
        else {
            cell.selectionStyle = .default
            cell.accessoryType = selectedIndexPath.contains(indexPath) ? .checkmark : .none
            cell.textLabel?.text = tables[indexPath.section].propertiesName[indexPath.row]
            cell.detailTextLabel?.text = nil
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if selectedIndexPath.contains(indexPath), let index = selectedIndexPath.index(of: indexPath) {
            selectedIndexPath.remove(at: index)
            cell?.accessoryType = .none
        }
        else {
            selectedIndexPath.append(indexPath)
            cell?.accessoryType = .checkmark
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 && action == .default ? 60 : 44
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return action == .default ? (section == 0 ? "Properties" : "Relationships") :
            tables[section].name + " AS " + (tables[section].customAlias ?? tables[section].alias)
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView, view.textLabel?.text?.contains(" AS ") ?? false {
            let attributtedString = NSMutableAttributedString(string: tables[section].name)
            attributtedString.append(NSAttributedString(string: " AS ", attributes: [NSForegroundColorAttributeName : UIColor.blue]))
            attributtedString.append(NSAttributedString(string: tables[section].customAlias ?? tables[section].alias))
            view.textLabel?.attributedText = attributtedString
        }
    }
}
