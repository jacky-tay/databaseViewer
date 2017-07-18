//
//  DatabaseTableViewController.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 18/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

class DatabaseTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.groupTableViewBackground
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.backgroundColor = UIColor.clear
            view.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin)
            view.backgroundView?.backgroundColor = UIColor(white: 0.975, alpha: 1)
            view.textLabel?.textColor = UIColor.gray
        }
    }
}
