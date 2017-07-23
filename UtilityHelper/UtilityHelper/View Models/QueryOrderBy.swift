//
//  QueryOrderBy.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 21/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class QueryOrderBy: QuerySelect {

    private var selectedOrderedIndexPath = [(IndexPath, OrderBy)]()
    
    override func doneIsClicked() {
        let properties = selectedOrderedIndexPath.flatMap { [weak self] item -> AliasPropertyOrder? in
            if let table = self?.list[item.0.section] {
                return AliasPropertyOrder(alias: table.alias, propertyName: table.properties[item.0.row].name, order: item.1)
            }
            return nil
        }
        queryRequest?.didOrderBy(properties: properties)
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getRightDetailCell(from: tableView, indexPath: indexPath)
        cell.textLabel?.text = list[indexPath.section].properties[indexPath.row].name
        cell.selectionStyle = .default
        cell.accessoryType = .none
        cell.detailTextLabel?.text = nil
        cell.detailTextLabel?.textColor = cell.tintColor
        if let order = selectedOrderedIndexPath.first(where: { $0.0 == indexPath }) {
            cell.detailTextLabel?.text = order.1.description
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.detailTextLabel?.text = nil
        cell?.accessoryType = .checkmark
        if let index = selectedOrderedIndexPath.index(where: { $0.0 == indexPath }) {
            if selectedOrderedIndexPath[index].1 == .asc {
                selectedOrderedIndexPath[index].1 = .desc
                cell?.detailTextLabel?.text = OrderBy.desc.description
            }
            else {
                selectedOrderedIndexPath.remove(at: index)
                cell?.accessoryType = .none
            }
        }
        else {
            selectedOrderedIndexPath.append((indexPath, .asc))
            cell?.detailTextLabel?.text = OrderBy.asc.description
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
