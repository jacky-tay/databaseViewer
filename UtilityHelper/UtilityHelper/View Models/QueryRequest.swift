//
//  QueryRequest.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 18/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

class QueryRequest: NSObject, ExecuteTableViewCellDelegate {
    weak var delegate: GenericTableViewModelDelegate?
    weak var navigationController: UINavigationController?
    
    enum BarButton: String {
        case done = "Done"
        case edit = "Edit"
    }
    
    fileprivate let semiModalTransitioningDelegate = SemiModalTransistioningDelegate()
    fileprivate var doneButton: UIBarButtonItem!
    fileprivate var editButton: UIBarButtonItem!
    
    var selected = [AliasProperty]()
    var from: DatabaseAliasTable!
    var joins = [JoinByDatabaseAlias]()
    var wheres: WhereClause?
    var groupBy = [AliasProperty]()
    var having = [AliasProperty]()
    var orderBy = [AliasPropertyOrder]()
    
    init(from: AliasTable) {
        self.selected = from.propertiesToAliasProperties()
        self.from = from.toDatabaseAliasTable()
        super.init()
        
        doneButton = UIBarButtonItem(title: BarButton.done.rawValue, style: .plain, target: self, action: #selector(barButtonItemDidClicked(sender:)))
        editButton = UIBarButtonItem(title: BarButton.edit.rawValue, style: .plain, target: self, action: #selector(barButtonItemDidClicked(sender:)))
    }
    
    func getQueryActionViewModel(action: QueryAction) -> GenericTableViewModel {
        if action == .join {
            return joins.isEmpty ? QueryJoinRequest(databaseAliasTable: from, queryRequest: self) : QueryJoinRequestWithTableOptions(queryRequest: self)
        }
        else if action == .where && wheres != nil {
            return QueryWhereInitiate(queryRequest: self, bracketHasEnded: false)
        }
        else if action == .where {
            return QueryWhere(queryRequest: self, action: action)
        }
        else if action == .having {
            return QueryHaving(queryRequest: self)
        }
        else if action == .orderBy {
            return QueryOrderBy(queryRequest: self, action: action)
        }
        return QuerySelect(queryRequest: self, action: action)
    }
    
    func getSelectableDatabaseAliasTables() -> [DatabaseAliasTable] {
        var list = [from]
        list.append(contentsOf: joins.flatMap { [$0, $0.otherTable] })
        return list.distinct()
    }
    
    func getSelectableDatabaseAliasTableWithProperties(includeWildCard: Bool) -> [DatabaseAliasTableWithProperties] {
        return toAliasTables().map { $0.toDatabaseAliasTableWithProperties(includeWildCard: includeWildCard) }
    }
    
    func toAliasTables() -> [AliasTable] {
        return getSelectableDatabaseAliasTables().flatMap { $0.toAliasTable() }
    }
    
    func getDatabaseAliasTable(from alias: String) -> DatabaseAliasTable? {
        return getSelectableDatabaseAliasTables().first { $0.alias == alias }
    }
    
    func getProperty(from aliasProperty: AliasProperty?) -> Property? {
        guard let alias = aliasProperty?.alias, let propertyName = aliasProperty?.propertyName else {
            return nil
        }
        return getDatabaseAliasTable(from: alias)?.toAliasTable()?.properties.first { $0.name == propertyName }
    }
    
    func insert(statement: Statement, whereOption: WhereOptions?, endLastBracket: Bool?) {
        wheres = wheres?.insert(statement: statement, whereOption: whereOption, endLastBracket: endLastBracket) ?? .base(statement)
    }
    
    func reload() {
        delegate?.reload()
        print()
    }
    
    fileprivate func getSection(of section: QueryAction) -> Int {
        switch section {
        case .select:   return 0
        case .from:     return 1
        case .join:     return 2
        case .where:    return (wheres == nil ? 1 : 2) + joins.count
        case .groupBy:  return (groupBy.isEmpty ? 0 : 1) + getSection(of: .where)
        case .having:   return (having.isEmpty ? 0 : 1) + getSection(of: .groupBy)
        case .orderBy:  return (orderBy.isEmpty ? 0 : 1) + getSection(of: .having)
        case .execute:  return 1 + getSection(of: .orderBy)
        default:        return 0
        }
    }
    
    func update(cell: UITableViewCell, indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        cell.selectionStyle = .none
        cell.detailTextLabel?.text = nil
        if section == 0, joins.isEmpty {
            cell.textLabel?.text = selected[row].propertyName
            cell.selectionStyle = .default
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
                              (" AS ", MaterialColor.blue),
                              (from.alias, nil)])
        }
        else if section > 1 && section < joins.count + 2, row == 0 {
            let join = joins[section - 2]
            cell.textLabel?.attributedText = NSMutableAttributedString
                .build(from: [(join.otherTable.tableName, nil),
                              (" AS ", MaterialColor.blue),
                              (join.otherTable.alias, nil)])
        }
        else if section == getSection(of: .groupBy) {
            cell.textLabel?.text = groupBy[row].description
        }
        else if section == getSection(of: .having) {
            cell.textLabel?.text = having[row].description
        }
        else if section == getSection(of: .orderBy) {
            cell.selectionStyle = .default
            cell.textLabel?.attributedText = orderBy[row].getAttributedString()
        }
    }
    
    // MARK: - Actions
    dynamic fileprivate func barButtonItemDidClicked(sender: UIBarButtonItem) {
        if let action = QueryAction(rawValue: sender.title ?? "") {
            let vc = GenericTableViewController.getViewController(viewModel: getQueryActionViewModel(action: action))
            navigationController?.presentViewControllerModally(vc, transitioningDelegate: semiModalTransitioningDelegate)
        }
        else if sender.title == BarButton.edit.rawValue {
            delegate?.update(editing: true)
            delegate?.update(rightBarButton: doneButton)
        }
        else if sender.title == BarButton.done.rawValue {
            delegate?.update(editing: false)
            delegate?.update(rightBarButton: editButton)
        }
    }
    
    // MARK: - ExecuteTableViewCellDelegate
    func execute() {
        print("Execute...")
        let tables = getSelectableDatabaseAliasTables()
        for table in tables {
            FetchResult.executeAndProcess(aliasTable: table, selected: selected, whereClause: wheres, groupBy: groupBy, orderBy: orderBy)
        }
    }
    
    func getTintColor() -> UIColor {
        return delegate?.getTintColor() ?? MaterialColor.blue
    }
}

// MARK: - GenericTableViewModel
extension QueryRequest: GenericTableViewModel {
    
    func viewDidLoad(_ viewController: GenericTableViewController) {
        setToolbar(viewController)
        viewController.hidesBottomBarWhenPushed = true
        viewController.navigationItem.title = "Query"
        viewController.navigationItem.rightBarButtonItem = editButton
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
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        let whereCount = wheres == nil ? 0 : 1
        let havingCount = (having.isEmpty ? 0 : 1)
        let groupCount = (groupBy.isEmpty ? 0 : 1)
        let orderCount = (orderBy.isEmpty ? 0 : 1)
        // 3 = select + from + execute
        return 3 + joins.count + whereCount + havingCount + groupCount + orderCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:     return selected.count
        case 1:     return 1
        case 2 ..< (2 + joins.count):   return (joins[section - 2].onConditions?.getCount() ?? 0) + 1
        case getSection(of: .where):    return wheres?.getCount() ?? 0
        case getSection(of: .groupBy):  return groupBy.count
        case getSection(of: .having):   return having.count
        case getSection(of: .orderBy):  return orderBy.count
        case getSection(of: .execute):  return 1
        default:    return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        if section == getSection(of: .execute) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExecuteTableViewCell", for: indexPath)
            (cell as? ExecuteTableViewCell)?.set(delegate: self)
            return cell
        }
        else if section > 1 && section < joins.count + 2 &&
            indexPath.row > 0 && // first row is joined table name
            joins[section - 2].onConditions != nil, // must have conditions
            let whereClause = joins[section - 2].onConditions?.getDescription(row: indexPath.row - 1),
            let cell = getWhereClauseTableViewCell(from: tableView, indexPath: indexPath) as? WhereClauseTableViewCell {
            cell.updateContent(statement: whereClause, row: indexPath.row - 1)
            return cell
        }
        else if section == getSection(of: .where),
            let whereClause = wheres?.getDescription(row: indexPath.row),
            let cell = getWhereClauseTableViewCell(from: tableView, indexPath: indexPath) as? WhereClauseTableViewCell {
            cell.updateContent(statement: whereClause, row: indexPath.row)
            return cell
        }
        
        let cell = getCell(from: tableView, indexPath: indexPath)
        cell.detailTextLabel?.text = nil
        update(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !orderBy.isEmpty && indexPath.section == getSection(of: .orderBy) {
            orderBy[indexPath.row].toggleOrder()
            tableView.cellForRow(at: indexPath)?.textLabel?.attributedText = orderBy[indexPath.row].getAttributedString()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var queryAction: QueryAction?
        switch section {
        case 0:     queryAction = .select
        case 1:     queryAction = .from
        case 2 ..< (2 + joins.count):   return joins[section - 2].joinType.description
        case getSection(of: .where):   queryAction = .where
        case getSection(of: .groupBy):  queryAction = .groupBy
        case getSection(of: .having):   queryAction = .having
        case getSection(of: .orderBy):  queryAction = .orderBy
        default:    return nil
        }
        return queryAction?.description
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.contentView.backgroundColor = UIColor(white: 0.95, alpha: 0.9)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !(indexPath.section == 1 || indexPath.section == getSection(of: .execute))
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.section == 0 || (!orderBy.isEmpty && indexPath.section == getSection(of: .orderBy))) && self.tableView(tableView, numberOfRowsInSection: indexPath.section) > 1
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard indexPath.section != 1 else {
            return nil
        }
        let edit = UITableViewRowAction(style: .normal, title: "Edit", handler: { [weak self] (action, removeIndexPath) in
            self?.remove(tableView, at: removeIndexPath)
        })
        
        let remove = UITableViewRowAction(style: .destructive, title: "Remove", handler: { [weak self] (action, removeIndexPath) in
            self?.remove(tableView, at: removeIndexPath)
        })
        return indexPath.section == 0 ? [remove, edit] : [remove]
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section == 0 {
            let select = selected.remove(at: sourceIndexPath.row)
            selected.insert(select, at: destinationIndexPath.row)
        }
        else if sourceIndexPath.section == getSection(of: .orderBy) {
            let order = orderBy.remove(at: sourceIndexPath.row)
            orderBy.insert(order, at: destinationIndexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            let row = sourceIndexPath.section < proposedDestinationIndexPath.section ? tableView.numberOfRows(inSection: sourceIndexPath.section) - 2 : 0
            return IndexPath(row: row, section: sourceIndexPath.section)
        }
        //        else if proposedDestinationIndexPath.row + 1 == fields[proposedDestinationIndexPath.section].fields.count {
        //            return IndexPath(row: proposedDestinationIndexPath.row - 1, section: proposedDestinationIndexPath.section)
        //        }
        return proposedDestinationIndexPath
    }
    
    private func remove(_ tableView: UITableView, at indexPath: IndexPath) {
        //        fields[indexPath.section].fields.remove(at: indexPath.row)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        tableView.isEditing = false
    }
}
