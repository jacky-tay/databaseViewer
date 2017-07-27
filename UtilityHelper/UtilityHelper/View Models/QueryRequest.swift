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
    
    enum BarButton: String {
        case execute = "Execute"
        case done = "Done"
        case edit = "Edit"
    }
    
    fileprivate let semiModalTransitioningDelegate = SemiModalTransistioningDelegate()
    fileprivate var excuteButton: UIBarButtonItem!
    fileprivate var doneButton: UIBarButtonItem!
    fileprivate var editButton: UIBarButtonItem!
    
    var selected = [AliasProperty]()
    var from: DatabaseTableAlias!
    var joins = [JoinByDatabaseAlias]()
    var wheres = [AliasProperty]()
    var groupBy = [AliasProperty]()
    var having = [AliasProperty]()
    var orderBy = [AliasPropertyOrder]()
    
    init(from: SelectedTable) {
        self.selected = from.propertiesToAliasProperties()
        self.from = from.toDatabaseTableAlias()
        super.init()
        
        excuteButton = UIBarButtonItem(title: BarButton.execute.rawValue, style: .plain, target: self, action: #selector(barButtonItemDidClicked(sender:)))
        doneButton = UIBarButtonItem(title: BarButton.done.rawValue, style: .plain, target: self, action: #selector(barButtonItemDidClicked(sender:)))
        editButton = UIBarButtonItem(image: StyleKit.imageOfReorder, style: .plain, target: self, action: #selector(barButtonItemDidClicked(sender:)))
    }
    
    func getQueryActionViewModel(action: QueryAction) -> GenericTableViewModel {
        if action == .join {
            return joins.isEmpty ? QueryJoinRequest(databaseTableAlias: from, queryRequest: self) : QueryJoinRequestWithTableOptions(queryRequest: self)
        }
        else if action == .where {
            return QueryWhere(queryRequest: self, action: action)
        }
        else if action == .orderBy {
            return QueryOrderBy(queryRequest: self, action: action)
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
    
    func getDatabaseTableAlias(from alias: String) -> DatabaseTableAlias? {
        return getSelectableDatabaseTableAlias().first { $0.alias == alias }
    }
    
    func reload() {
        delegate?.reload()
    }
    
    fileprivate func getSection(of section: QueryAction) -> Int {
        switch section {
        case .select:   return 0
        case .from:     return 1
        case .join:     return 2
        case .where:    return (wheres.isEmpty ? 1 : 2) + joins.count
        case .groupBy:  return (groupBy.isEmpty ? 0 : 1) + getSection(of: .where)
        case .having:   return (having.isEmpty ? 0 : 1) + getSection(of: .groupBy)
        case .orderBy:  return (orderBy.isEmpty ? 0 : 1) + getSection(of: .having)
        default:        return 0
        }
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
        else if section == getSection(of: .where) {
            cell.textLabel?.text = "WIP"
        }
        else if section == getSection(of: .groupBy) {
            cell.textLabel?.text = groupBy[row].description
        }
        else if section == getSection(of: .having) {
            cell.textLabel?.text = having[row].description
        }
        else if section == getSection(of: .orderBy) {
            cell.textLabel?.text = orderBy[row].description
        }
    }
    
    // MARK: - Actions
    dynamic fileprivate func barButtonItemDidClicked(sender: UIBarButtonItem) {
        if let action = QueryAction(rawValue: sender.title ?? "") {
            let vc = GenericTableViewController.getViewController(viewModel: getQueryActionViewModel(action: action))
            navigationController?.presentViewControllerModally(vc, transitioningDelegate: semiModalTransitioningDelegate)
        }
        else if sender.image != nil {
            delegate?.update(editing: true)
            delegate?.update(rightBarButtons: [doneButton])
        }
        else if sender.title == BarButton.done.rawValue {
            delegate?.update(editing: false)
            delegate?.update(rightBarButtons: [excuteButton, editButton])
        }
    }
}

// MARK: - GenericTableViewModel
extension QueryRequest: GenericTableViewModel {
    
    func viewDidLoad(_ viewController: GenericTableViewController) {
        setToolbar(viewController)
        viewController.hidesBottomBarWhenPushed = true
        viewController.navigationItem.title = "Query"
        viewController.navigationItem.rightBarButtonItems = [excuteButton, editButton]
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
        return 2 + // selected + from
            joins.count +
            (having.isEmpty ? 0 : 1) +
            (groupBy.isEmpty ? 0 : 1) +
            (orderBy.isEmpty ? 0 : 1)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:     return selected.count
        case 1:     return 1
        case 2 ..< (2 + joins.count):   return (joins[section - 2].onConditions?.count ?? 0) + 1
        case getSection(of: .where):   return wheres.count
        case getSection(of: .groupBy):  return groupBy.count
        case getSection(of: .having):   return having.count
        case getSection(of: .orderBy):  return orderBy.count
        default:    return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(from: tableView, indexPath: indexPath)
        cell.detailTextLabel?.text = nil
        update(cell: cell, indexPath: indexPath)
        return cell
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
        return indexPath.section != 1
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true//indexPath.section == 0
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
