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
}

@objc protocol GenericTableViewModel: UITableViewDataSource, UITableViewDelegate {
    weak var navigationController: UINavigationController? { get set }
    func viewDidLoad(_ viewController: GenericTableViewController)
    @objc optional func viewWillAppear(_ viewController: GenericTableViewController)
    @objc optional func viewWillDisappeared()
    @objc optional func doneIsClicked()
}

extension GenericTableViewModel {
    
    func set(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func addCloseOnLeftHandSide(_ viewController: GenericTableViewController) {
        guard viewController.navigationController?.viewControllers.first == viewController else {
            return
        }
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: viewController, action: #selector(viewController.dismissViewController))
    }
    
    func addDoneOnRightHandSide(_ viewController: GenericTableViewController) {
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: viewController, action: #selector(viewController.doneIsClicked(_:)))
    }
    
    func getCell(from tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "DatabaseTableRowTableViewCell", for: indexPath)
    }
    
    func getRightDetailCell(from tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "DatabaseTableRowRightTableViewCell", for: indexPath)
    }
    
    func applyHeaderLayout(view: UIView) {
        if let headerView = view as? UITableViewHeaderFooterView,
            let header = headerView.textLabel?.text {
            let range = NSString(string: header).range(of: " AS ")
            let attributedText = NSMutableAttributedString(string: header)
            attributedText.addAttributes([NSForegroundColorAttributeName : Material.blue], range: range)
            headerView.textLabel?.attributedText = attributedText
        }
    }
    
    func applyFooterLayout(view: UIView) {
        if let view = view as? UITableViewHeaderFooterView {
            view.backgroundColor = UIColor.clear
            view.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin)
            view.backgroundView?.backgroundColor = UIColor(white: 0.975, alpha: 1)
            view.textLabel?.textColor = UIColor.gray
        }
    }
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
        viewModel.viewWillDisappeared?()
    }
    
    // GenericTableViewModelDelegate
    func update(insertRows: [IndexPath], insertSections: [Int]) {
        tableView.beginUpdates()
        tableView.insertRows(at: insertRows, with: .automatic)
        insertSections.forEach { [weak self] in self?.tableView.insertSections(IndexSet(integer: $0), with: .automatic) }
        tableView.endUpdates()
    }
}
