//
//  QueryRequest.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 18/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

class QueryRequest: NSObject {
    weak var delegate: GenericTableViewModelDelegate?
    weak var navigationController: UINavigationController?
    
    let semiModalTransitioningDelegate = SemiModalTransistioningDelegate()
    
    var selected = [AliasProperty]()
    var from: DatabaseTableAlias!
    var joins = [JoinByDatabaseAlias]()
    var having = [DatabaseTableProperty]()
    var groupBy = [AliasProperty]()
    var orderBy = [AliasPropertyOrder]()
    
    init(from: SelectedTable) {
        self.selected = from.propertiesToAliasProperties()
        self.from = from.toDatabaseTableAlias()
    }
    
    func getQueryActionViewModel(action: QueryAction) -> GenericTableViewModel {
        if action == .join {
            return joins.isEmpty ? QueryJoinRequest(databaseTableAlias: from, queryRequest: self) : QueryJoinRequestWithTableOptions(queryRequest: self)
        }
        else if action == .orderBy {
            return QueryOrderBy(queryRequest: self, action: .orderBy)
        }
        return QuerySelect(queryRequest: self, action: action)
    }
    
    func getSelectableDatabaseTableAlias() -> [DatabaseTableAlias] {
        var list = [from]
        list.append(contentsOf: joins.flatMap { [$0, $0.otherTable] })
        return list.distinct()
    }
    
    func getSelectableDatabaseTableAliasWithProperties(includeWildCard: Bool) -> [DatabaseTableAliasWithProperties] {
        return toSelectedTables().map { $0.toDatabaseTableAliasWithProperties(includeWildCard: includeWildCard) }
    }
    
    func toSelectedTables() -> [SelectedTable] {
        return getSelectableDatabaseTableAlias().flatMap { $0.toSelectedTable() }
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
        else if section > 1 && section < joins.count + 2, row == 0 {
            let join = joins[section - 2]
            cell.textLabel?.attributedText = NSMutableAttributedString
                .build(from: [(join.otherTable.tableName, nil),
                              (" AS ", Material.blue),
                              (join.otherTable.alias, nil)])
            cell.detailTextLabel?.text = !(join.onConditions?.isEmpty ?? true) ? "ON" : nil
        }
        else if section > 1 && section < joins.count + 2 {
            cell.textLabel?.text = joins[section - 2].getConditionDescription(at: row - 1)
            let conditionCount = joins[section - 2].onConditions?.count ?? 0
            cell.detailTextLabel?.text = row - 2 < conditionCount ? "AND" : nil
        }
    }
}

// MARK: - GenericTableViewModel
extension QueryRequest: GenericTableViewModel {
    
    func viewDidLoad(_ viewController: GenericTableViewController) {
        setToolbar(viewController)
        viewController.hidesBottomBarWhenPushed = true
        viewController.navigationItem.title = "Query"
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Execute", style: .plain, target: self, action: #selector(execute(sender:)))
    }
    
    private func setToolbar(_ viewController: GenericTableViewController) {
        let items: [QueryAction] = [.select, .join, .where, .groupBy, .having, .orderBy]
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        viewController.toolbarItems = items.enumerated().flatMap { enumerate -> [UIBarButtonItem] in
            let item = UIBarButtonItem(title: enumerate.element.rawValue, style: .plain, target: self, action: #selector(barButtonItemDidClicked(sender:)))
            return enumerate.offset + 1 < items.count ? [item, space] : [item]
        }
    }
    
    func viewWillAppear(_ viewController: GenericTableViewController) {
        viewController.tableView.reloadData()
        viewController.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    func viewWillDisappeared(_ viewController: GenericTableViewController) {
        viewController.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    private dynamic func execute(sender: UIBarButtonItem) {
        
    }
    
    // MARK: - Actions
    dynamic private func barButtonItemDidClicked(sender: UIBarButtonItem) {
        guard let action = QueryAction(rawValue: sender.title ?? "") else {
            return
        }
        
        let vc = GenericTableViewController.getViewController(viewModel: getQueryActionViewModel(action: action))
        navigationController?.presentViewControllerModally(vc, transitioningDelegate: semiModalTransitioningDelegate)
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 + // selected + from
            joins.count +
            (having.isEmpty ? 0 : 1) +
            (groupBy.isEmpty ? 0 : 1) +
            (orderBy.isEmpty ? 0 : 1)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return selected.count
        }
        else if section == 1 {
            return 1
        }
        else if section > 1 && section < joins.count + 2 {
            return (joins[section - 2].onConditions?.count ?? 0) + 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(from: tableView, indexPath: indexPath)
        cell.detailTextLabel?.text = nil
        update(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.contentView.backgroundColor = UIColor(white: 0.95, alpha: 0.9)
        }
    }
}

// MARK: - QueryActionDelegate
extension QueryRequest: QueryActionDelegate {
    
    func didSelect(properties: [(AliasProperty)]) {
        let startIndex = selected.count
        selected.append(contentsOf: properties)
        delegate?.update(insertRows: (startIndex ..< (startIndex + properties.count)).map { IndexPath(row: $0, section: 0) } , insertSections: [])
    }
    
    func didOrderBy(properties: [(AliasPropertyOrder)]) {
        
    }
    
    func didGroupBy(properties: [(AliasProperty)]) {
        groupBy.append(contentsOf: properties)
    }
    
    func addRelationship(with: JoinByDatabaseAlias) {
        joins.append(with)
        delegate?.update(insertRows: [], insertSections: [1 + joins.count])
    }
}
