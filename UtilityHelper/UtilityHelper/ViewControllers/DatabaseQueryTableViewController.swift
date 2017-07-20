//
//  DatabaseQueryTableViewController.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 18/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

protocol DatabaseQueryTableViewControllerDelegate: class {
    func update(insertRows: [IndexPath], insertSections: [Int])
}

class DatabaseQueryTableViewController: DatabaseTableViewController, DatabaseQueryTableViewControllerDelegate {
    
    var queryRequest: QueryRequest!
    var selectedJoinTable: DatabaseTableAlias?
    let semiModalTransitioningDelegate = SemiModalTransistioningDelegate()

    static func getViewController(table: SelectedTable) -> DatabaseQueryTableViewController? {
        let storyboard = UIStoryboard(name: "DatabaseViewer", bundle: Bundle(for: DatabaseQueryTableViewController.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "DatabaseQueryTableViewController") as? DatabaseQueryTableViewController
        vc?.queryRequest = QueryRequest(from: table, delegate: vc)
        vc?.selectedJoinTable = vc?.queryRequest.from
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Query"
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
        let items: [QueryAction] = [.select, .join, .where, .groupBy, .having, .orderBy]
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
            if let vc = DatabaseTableDetailsViewController.getViewController(queryRequest: queryRequest, action: action) {
                navigationController?.presentViewControllerModally(vc, transitioningDelegate: semiModalTransitioningDelegate)
            }
        }
    }

    private func showJoinOptions() {
        let alert = UIAlertController(title: "Join With", message: selectedJoinTable?.tableName, preferredStyle: .actionSheet)
        for join in Join.getAllJoins() {
            alert.addAction(UIAlertAction(title: join.description, style: .default) { [weak self] (action) in
                self?.didSelectedJoin(sender: action)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        navigationController?.present(alert, animated: true, completion: nil)
    }

    private func didSelectedJoin(sender: UIAlertAction) {
        guard let join = Join(rawValue: sender.title?.components(separatedBy: " ").first?.uppercased() ?? "") else {
            return
        }
        if let selectedTable = selectedJoinTable?.toSelectedTable(),
            let vc = DatabaseTableListViewController.getViewController(joinType: join, with: selectedTable, delegate: queryRequest) {
            navigationController?.presentViewControllerModally(vc, transitioningDelegate: semiModalTransitioningDelegate)
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return queryRequest.getSectionCount()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queryRequest.getRowCount(for: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DatabaseTableRowTableViewCell", for: indexPath)
        queryRequest.update(cell: cell, indexPath: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return queryRequest.getSectionTitle(section: section)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.backgroundColor = UIColor.clear
            view.backgroundView?.backgroundColor = UIColor(white: 0.95, alpha: 0.9)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    // DatabaseQueryTableViewControllerDelegate
    func update(insertRows: [IndexPath], insertSections: [Int]) {
        tableView.beginUpdates()
        tableView.insertRows(at: insertRows, with: .automatic)
        insertSections.forEach { [weak self] in self?.tableView.insertSections(IndexSet(integer: $0), with: .automatic) }
        tableView.endUpdates()
    }
}
