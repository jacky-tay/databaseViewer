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
    private var list = [WhereOptions]()
    
    init(queryRequest: QueryRequest, bracketHasEnded: Bool) {
        self.queryReuest = queryRequest
        if queryRequest.wheres.isEmpty {
            list = [.startWithBracket, .startWithoutBracket]
        }
        else if bracketHasEnded || (queryRequest.wheres.last?.isBase() ?? false) {
            list = [.startWithBracket, .and, .or]
        }
        else if let whereClause = queryRequest.wheres.last, case WhereClause.add(_) = whereClause {
            list = [.endBracket, .and]
        }
        else if let whereClause = queryRequest.wheres.last, case WhereClause.or(_) = whereClause {
            list = [.endBracket, .or]
        }
    }
    
    func viewDidLoad(_ viewController: GenericTableViewController) {
        viewController.navigationItem.title = QueryAction.where.description
        addCloseOnLeftHandSide(viewController)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(from: tableView, indexPath: indexPath)
        cell.textLabel?.text = list[indexPath.row].description
        cell.detailTextLabel?.text = nil
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let queryRequest = queryReuest else {
            return
        }
        var viewModel: GenericTableViewModel?
        let option = list[indexPath.row]
        let andOr: [WhereOptions] = [.and, .or]
        if option == .endBracket {
            viewModel = QueryWhereInitiate(queryRequest: queryRequest, bracketHasEnded: true)
        }
        else {
            viewModel = QueryWhere(queryRequest: queryRequest, action: .where)
        }
        
        if option == .startWithoutBracket {
            queryRequest.wheres.append(WhereClause.base(nil))
        }
        else if option == .startWithBracket {
            queryRequest.wheres.append(WhereClause.bracket([]))
        }
        else if andOr.contains(option) {
            let clause = queryRequest.wheres.remove(at: queryRequest.wheres.count - 1)
            if case .base(let statement) = clause {
                if let _statement = statement, option == .and {
                    queryRequest.wheres.append(WhereClause.add([.base(_statement), .base(nil)]))
                }
                else if let _statement = statement, option == .or {
                    queryRequest.wheres.append(WhereClause.add([.base(_statement), .base(nil)]))
                }
            }
            else {
                queryRequest.wheres.append(clause)
            }
        }
        
        if let viewModel = viewModel,
            let vc = GenericTableViewController.getViewController(viewModel: viewModel) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
