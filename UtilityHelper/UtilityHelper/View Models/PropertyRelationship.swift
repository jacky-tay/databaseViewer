//
//  PropertyRelationship.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 21/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class PropertyRelationship: NSObject, GenericTableViewModel {
    
    weak var navigationController: UINavigationController?
    private let databaseTable: DatabaseAliasTableWithPropertiesRelationships!
    
    init(databaseTable: DatabaseAliasTableWithPropertiesRelationships) {
        self.databaseTable = databaseTable
    }
    
    func viewDidLoad(_ viewController: GenericTableViewController) {
        viewController.navigationItem.title = databaseTable.tableName
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return databaseTable.relationships.isEmpty ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? databaseTable.properties.count : databaseTable.relationships.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(from: tableView, indexPath: indexPath)
        cell.accessoryType = .none
        cell.selectionStyle = .none
        if indexPath.section == 0 {
            cell.textLabel?.text = databaseTable.properties[indexPath.row].name
            cell.detailTextLabel?.text = databaseTable.properties[indexPath.row].attributeType.description
        }
        else {
            cell.textLabel?.text = databaseTable.relationships[indexPath.row]
            cell.detailTextLabel?.text = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 60 : 44
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Properties" : "Relationships"
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "\(self.tableView(tableView, numberOfRowsInSection: section)) \(section == 0 ? "properties" : "relationships")"
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        applyFooterLayout(view: view)
    }
}
