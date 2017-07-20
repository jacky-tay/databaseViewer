//
//  QueryRequest.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 18/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

class QueryRequest {
    weak var delegate: DatabaseQueryTableViewControllerDelegate?
    var selected = [AliasProperty]()
    var from: DatabaseTableAlias!
    var joins = [JoinByDatabaseAlias]()
    var having = [DatabaseTableProperty]()
    var groupBy = [DatabaseTableProperty]()
    var orderBy = [OrderBy]()
    
    init(from: SelectedTable, delegate: DatabaseQueryTableViewControllerDelegate?) {
        self.selected = from.propertiesToAliasProperties()
        self.from = from.toDatabaseTableAlias()
        self.delegate = delegate
    }
    
    func toSelectedTables() -> [SelectedTable] {
        var list = [SelectedTable]()
        list.append(contentsOf: Set(joins.flatMap { [$0, $0.otherTable] }).flatMap { $0.toSelectedTable() })
        return list
    }
    
    func getRowCount(for section: Int) -> Int {
        if section == 0 {
            return selected.count
        }
        else if section == 1 {
            return 1
        }
        else if section > 1 && section < joins.count + 2 {
            return 1
        }
        return 0
    }
    
    func getSectionCount() -> Int {
        return 2 + // selected + from
            joins.count +
            (having.isEmpty ? 0 : 1) +
            (groupBy.isEmpty ? 0 : 1) +
            (orderBy.isEmpty ? 0 : 1)
    }
    
    func getSectionTitle(section: Int) -> String? {
        if section == 0 {
            return "Select"
        }
        else if section == 1 {
            return "From"
        }
        else if section > 1 && section < joins.count + 2 {
            return joins[section - 2].joinType.description
        }
        return nil
    }
    
    func update(cell: UITableViewCell, indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        cell.detailTextLabel?.text = nil
        if section == 0, joins.isEmpty {
            cell.textLabel?.text = selected[row].propertyName
        }
        else if section == 0, !joins.isEmpty {
            cell.textLabel?.text = ".".joined(contentsOf: [selected[row].alias, selected[row].propertyName])
        }
        else if section == 1, joins.isEmpty {
            cell.textLabel?.text = from.tableName
        }
        else if section == 1, !joins.isEmpty {
            cell.textLabel?.attributedText = NSMutableAttributedString
                .build(from: [(from.tableName, nil),
                              (" AS ", Material.blue),
                              (from.alias, nil)])
        }
        else if section > 1 && section < joins.count + 2 {
            let join = joins[section - 2]
            cell.textLabel?.attributedText = NSMutableAttributedString
                .build(from: [(join.otherTable.tableName, nil),
                              (" AS ", Material.blue),
                              (join.otherTable.alias, nil)])
        }
    }
}

// MARK: - QueryActionDelegate
extension QueryRequest: QueryActionDelegate {
    
    func didSelect(properties: [(AliasProperty)]) {
        let startIndex = selected.count
        selected.append(contentsOf: properties)
        delegate?.update(insertRows: (startIndex ..< (startIndex + properties.count)).map { IndexPath(row: $0, section: 0) } ,
                         insertSections: [])
    }
    
    func didOrderBy(properties: [(DatabaseTableProperty)]) {
        
    }
    
    func didGroupBy(properties: [(DatabaseTableProperty)]) {
        groupBy.append(contentsOf: properties)
    }
    
    func addRelationship(with: JoinByDatabaseAlias) {
        joins.append(with)
        delegate?.update(insertRows: [], insertSections: [1 + joins.count])
    }
}
