//
//  GenericTableViewController.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 21/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

protocol GenericTableViewModelDelegate: class {
    func reload()
    func getCellRow(at indexPath: IndexPath) -> UITableViewCell?
    func update(editing: Bool)
    func update(rightBarButton: UIBarButtonItem)
    func update(insertRows: [IndexPath], insertSections: [Int])
    func remove(rows: [IndexPath])
    func animateTable(in section: Int, reloadRows: [Int], insertRows: [Int], deleteRows: [Int])
    func dismissKeyboard()
    func getTintColor() -> UIColor
}

class GenericTableViewController: UITableViewController, InterceptableViewController, GenericTableViewModelDelegate {

    internal var viewModel: GenericTableViewModel!
    
    class func getViewController(viewModel: GenericTableViewModel) -> GenericTableViewController? {
        let storyboard = UIStoryboard(name: "DatabaseViewer", bundle: Bundle(for: GenericTableViewController.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "GenericTableViewController") as? GenericTableViewController
        vc?.viewModel = viewModel
        return vc
    }
    
    dynamic func doneIsClicked(_ sender: UIBarButtonItem) {
        viewModel.doneIsClicked?()
        dismissViewController()
    }
    
    dynamic func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyRoundCorner()
    }
    
    private func applyRoundCorner() {
        if navigationController?.transitioningDelegate is SemiModalTransistioningDelegate {
            let radius: CGFloat = 10
            let corners: UIRectCorner = [.topLeft, .topRight]
            navigationController?.navigationBar.applyRoundCorner(to: corners, radius: radius)
            view.applyRoundCorner(to: corners, radius: radius)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.set(navigationController: navigationController)
        view.backgroundColor = UIColor.groupTableViewBackground
        tableView.dataSource = viewModel
        tableView.delegate = viewModel
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 45
        tableView.tableFooterView = UIView()
        viewModel.viewDidLoad(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear?(self)
        applyRoundCorner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.viewWillDisappeared?(self)
    }
    
    // GenericTableViewModelDelegate
    func reload() {
        tableView.reloadData()
    }

    func getTintColor() -> UIColor {
        return tableView.tintColor
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func getCellRow(at indexPath: IndexPath) -> UITableViewCell? {
        return tableView.cellForRow(at: indexPath)
    }
    
    func update(editing: Bool) {
        view.endEditing(true)
        tableView.setEditing(editing, animated: true)
    }
    
    func update(rightBarButton: UIBarButtonItem) {
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func update(insertRows: [IndexPath], insertSections: [Int]) {
        tableView.reloadData()
//        tableView.beginUpdates()
//        tableView.insertRows(at: insertRows, with: .automatic)
//        insertSections.forEach { [weak self] in self?.tableView.insertSections(IndexSet(integer: $0), with: .automatic) }
//        tableView.endUpdates()
    }

    func remove(rows: [IndexPath]) {
        tableView.beginUpdates()
        tableView.deleteRows(at: rows, with: .automatic)
        tableView.endUpdates()
    }

    func animateTable(in section: Int, reloadRows: [Int], insertRows: [Int], deleteRows: [Int]) {
        tableView.beginUpdates()
        tableView.reloadRows(at: reloadRows.map { IndexPath(row: $0, section: section) }, with: .automatic)
        tableView.deleteRows(at: deleteRows.map { IndexPath(row: $0, section: section) }, with: .automatic)
        tableView.insertRows(at: insertRows.map { IndexPath(row: $0, section: section) }, with: .automatic)
        tableView.endUpdates()
    }
    
    // MARK: - InterceptableViewController
    func canIntercept() -> Bool {
        guard let interceptable = viewModel as? InterceptableViewController else {
            return false
        }
        return interceptable.canIntercept()
    }
}
