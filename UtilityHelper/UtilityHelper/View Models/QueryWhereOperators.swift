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
    private let aliasProperty: AliasProperty!
    private let whereOption: WhereOptions?
    private let endLastBracket: Bool?
    
    init(queryRequest: QueryRequest, alias: String, property: Property, whereOption: WhereOptions?, endLastBracket: Bool?) {
        self.queryRequest = queryRequest
        self.whereOption = whereOption
        self.endLastBracket = endLastBracket
        list = [("Comparison Operator", Comparator.getAll(filterBy: property.attributeType.getCategory())),
                ("Operator", Argument.getAll(filterBy: property.attributeType.getCategory()))]
        self.aliasProperty = AliasProperty(alias: alias, propertyName: property.name)
    }
    
    func viewDidLoad(_ viewController: GenericTableViewController) {
        viewController.navigationItem.title = aliasProperty.description
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
        let currentOperator = list[indexPath.section].1[indexPath.row]
        cell.textLabel?.text = currentOperator.description
        cell.selectionStyle = .default
        cell.accessoryType = currentOperator.showDisclosureIndicator() ? .disclosureIndicator : .none
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
            viewModel = QueryFetchIn(queryRequest: queryRequest, aliasProperty: aliasProperty, whereOption: whereOption, endLastBracket: endLastBracket)
        }
        else if [Argument.isNotNull, Argument.isNull].contains(where: { $0.description == selectedOperator.description }) {
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark

            let statement = Statement(aliasProperty: aliasProperty, argument: selectedOperator, values: [])
            queryRequest.insert(statement: statement, whereOption: whereOption, endLastBracket: endLastBracket)
            queryRequest.reload()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
        else if Argument.between.description == selectedOperator.description {
            viewModel = QueryBetweenOperatorTextInput(queryRequest: queryRequest, aliasProperty: aliasProperty, whereArgument: selectedOperator, whereOption: whereOption, endLastBracket: endLastBracket)
        }
        else {
            viewModel = QueryWhereOperatorTextInput(queryRequest: queryRequest, aliasProperty: aliasProperty, whereArgument: selectedOperator, whereOption: whereOption, endLastBracket: endLastBracket)
        }
        
        if let viewModel = viewModel,
            let vc = GenericTableViewController.getViewController(viewModel: viewModel) {
            (viewModel as? QueryOperatorTextInput)?.delegate = vc
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        applyHeaderLayout(view: view)
    }
}
