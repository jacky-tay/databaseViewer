//
//  QueryWhereOperators.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 23/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class QueryWhereOperators: NSObject, GenericTableViewModel {
    weak var navigationController: UINavigationController?
    weak var queryRequest: QueryRequest?
    internal var list: [(String, [WhereArgument])] = []
    private let alias: String!
    private let property: Property!
    
    init(queryRequest: QueryRequest, alias: String, property: Property) {
        self.queryRequest = queryRequest
        list = [("Comparison Operator", Comparator.getAll(filterBy: property.attributeType.getCategory())),
                ("Operator", Argument.getAll(filterBy: property.attributeType.getCategory()))]
        self.alias = alias
        self.property = property
    }
    
    func viewDidLoad(_ viewController: GenericTableViewController) {
        viewController.navigationItem.title = ".".joined(contentsOf: [alias, property?.name])
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(from: tableView, indexPath: indexPath)
        cell.textLabel?.text = list[indexPath.section].1[indexPath.row].description
        cell.selectionStyle = .default
        cell.accessoryType = .disclosureIndicator
        cell.detailTextLabel?.text = nil
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return list[section].0
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let queryRequest = queryRequest else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        let selectedOperator = list[indexPath.section].1[indexPath.row]
        var viewModel: GenericTableViewModel?
        if selectedOperator.description == Argument.in.description {
            viewModel = QueryFetchIn(queryRequest: queryRequest, alias: alias, property: property)
        }
        
        if let viewModel = viewModel,
            let vc = GenericTableViewController.getViewController(viewModel: viewModel) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        applyHeaderLayout(view: view)
    }
}
