//
//  QueryOrderBy.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 21/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class QueryOrderBy: QuerySelect {

    private var selectedOrderedIndexPaths = [(IndexPath, OrderBy)]()
    
    override func viewDidLoad(_ viewController: GenericTableViewController) {
        super.viewDidLoad(viewController)
        // show selected properties
        if let orders = queryRequest?.orderBy, !orders.isEmpty {
            for order in orders {
                if let section = list.index(where: { $0.alias == order.alias }),
                    let row = list[section].properties.index(where: { $0.name == order.propertyName }) {
                    selectedOrderedIndexPaths.append((IndexPath(row: row, section: section), order.order))
                }
            }
        }
    }
    
    override func doneIsClicked() {
        guard let queryRequest = queryRequest else {
            return
        }
        
        let properties = selectedOrderedIndexPaths.flatMap { [weak self] item -> AliasPropertyOrder? in
            if let table = self?.list[item.0.section] {
                return AliasPropertyOrder(alias: table.alias, propertyName: table.properties[item.0.row].name, order: item.1)
            }
            return nil
        }
        for index in stride(from: queryRequest.orderBy.count - 1, through: 0, by: -1) {
            if !properties.contains(queryRequest.orderBy[index]) {
                queryRequest.orderBy.remove(at: index)
            }
        }
        for order in properties where !queryRequest.orderBy.contains(order) {
            queryRequest.orderBy.append(order)
        }
        
        queryRequest.reload()
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getRightDetailCell(from: tableView, indexPath: indexPath)
        cell.textLabel?.text = list[indexPath.section].properties[indexPath.row].name
        cell.selectionStyle = .default
        cell.accessoryType = .none
        cell.detailTextLabel?.text = nil
        cell.detailTextLabel?.textColor = cell.tintColor
        if let order = selectedOrderedIndexPaths.enumerated().first(where: { $0.element.0 == indexPath }) {
            cell.detailTextLabel?.text = "\(order.element.1.description) \(order.offset + 1)"
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.detailTextLabel?.text = nil
        if let index = selectedOrderedIndexPaths.index(where: { $0.0 == indexPath }) {
            if selectedOrderedIndexPaths[index].1 == .asc {
                selectedOrderedIndexPaths[index].1 = .desc
                cell?.detailTextLabel?.text = "\(OrderBy.desc.description) \(index + 1)"
            }
            else {
                selectedOrderedIndexPaths.remove(at: index)
            }
        }
        else {
            selectedOrderedIndexPaths.append((indexPath, .asc))
            cell?.detailTextLabel?.text = "\(OrderBy.asc.description) \(selectedOrderedIndexPaths.count)"
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
