//
//  GenericTableViewModel.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 23/07/17.
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
    @objc optional func viewWillDisappeared(_ viewController: GenericTableViewController)
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
    
    func getTextFieldCell(from tableView: UITableView, indexPath: IndexPath) -> TextFieldTableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell", for: indexPath) as? TextFieldTableViewCell
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
            view.contentView.backgroundColor = UIColor.clear
            view.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin)
            view.backgroundView?.backgroundColor = UIColor(white: 0.975, alpha: 1)
            view.textLabel?.textColor = UIColor.gray
        }
    }
}
