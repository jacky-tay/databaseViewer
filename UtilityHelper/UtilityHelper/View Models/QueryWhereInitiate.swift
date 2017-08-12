//
//  QueryWhereInitiate.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 30/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class QueryWhereInitiate: NSObject, GenericTableViewModel {
    weak var navigationController: UINavigationController?
    private weak var queryReuest: QueryRequest!
    private var list = [(WhereCategory, [WhereOptions])]()
    
    init(queryRequest: QueryRequest, bracketHasEnded: Bool) {
        self.queryReuest = queryRequest
        list = [(.and, [.andWithBracket, .andWithoutBracket]),
                (.or, [.orWithBracket, .orWithoutBracket])]
        
        if !bracketHasEnded && (queryRequest.wheres?.isBracket() ?? false || queryRequest.wheres?.getLast()?.isBracket() ?? false) {
            list.insert((.default, [.endBracket]), at: 0)
        }
    }
    
    func viewDidLoad(_ viewController: GenericTableViewController) {
        viewController.navigationItem.title = QueryAction.where.description
        addCloseOnLeftHandSide(viewController)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].1.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(from: tableView, indexPath: indexPath)
        cell.textLabel?.text = list[indexPath.section].1[indexPath.row].description
        cell.detailTextLabel?.text = nil
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return list[section].0.description
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let queryRequest = queryReuest else {
            return
        }
        var viewModel: GenericTableViewModel?
        let option = list[indexPath.section].1[indexPath.row]
        if option == .endBracket {
            viewModel = QueryWhereInitiate(queryRequest: queryRequest, bracketHasEnded: true)
        }
        else {
            viewModel = QueryWhere(queryRequest: queryRequest, action: .where, whereOption: option)
        }
        
        if !(queryRequest.wheres?.isAdd() ?? true) && option.isAnd() {
            queryRequest.convertWhereClauseToBracketIfNeeded()
            queryRequest.insert(clause: .add([]))
        }
        else if !(queryRequest.wheres?.isOr() ?? true) && option.isOr() {
            queryRequest.convertWhereClauseToBracketIfNeeded()
            queryRequest.insert(clause: .or([]))
        }
        
        if option.isBracket() {
            queryRequest.insert(clause: .bracket(nil))
        }
        
        if let viewModel = viewModel,
            let vc = GenericTableViewController.getViewController(viewModel: viewModel) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
