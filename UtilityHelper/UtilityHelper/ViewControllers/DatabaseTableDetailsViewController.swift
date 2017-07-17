//
//  DatabaseTableDetailsViewController.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 17/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class DatabaseTableDetailsViewController: UITableViewController {

    private var table: Table!

    class func getViewController(table: Table) -> DatabaseTableDetailsViewController? {
        let storyboard = UIStoryboard(name: "DatabaseViewer", bundle: Bundle(for: DatabaseTableDetailsViewController.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "DatabaseTableDetailsViewController") as? DatabaseTableDetailsViewController
        vc?.table = table
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = table.name
        view.backgroundColor = UIColor.groupTableViewBackground
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return (table.relationships?.isEmpty ?? true) ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? table.propertiesName.count : table.relationships?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DatabaseTableRowTableViewCell", for: indexPath)
        if indexPath.section == 0, let property = table.properties[table.propertiesName[indexPath.row]] {
            cell.textLabel?.text = table.propertiesName[indexPath.row]
            cell.detailTextLabel?.text = property.description
        }
        else if indexPath.section == 1, let relationships = table.relationships {
            cell.textLabel?.text = relationships[indexPath.row]
            cell.detailTextLabel?.text = nil
        }
        cell.detailTextLabel?.textColor = UIColor.lightGray
        return cell
    }

   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 60 : 44
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Properties" : "Relationships"
    }
}
