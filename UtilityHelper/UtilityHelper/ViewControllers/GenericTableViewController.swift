//
//  GenericTableViewController.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 21/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

protocol GenericTableViewModelDelegate: class {
    func update(insertRows: [IndexPath], insertSections: [Int])
    func remove(rows: [IndexPath])
}

class GenericTableViewController: UITableViewController, GenericTableViewModelDelegate {

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
        viewModel.viewDidLoad(self)
        view.backgroundColor = UIColor.groupTableViewBackground
        tableView.dataSource = viewModel
        tableView.delegate = viewModel
        tableView.tableFooterView = UIView()
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
}
