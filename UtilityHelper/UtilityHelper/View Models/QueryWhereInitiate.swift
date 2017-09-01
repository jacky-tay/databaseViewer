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
    private weak var queryRequest: QueryRequest!
    private var list = [(WhereCategory, [WhereOptions])]()
    private let endLastBracket: Bool!
    private let dummyStatement: Statement!
    
    init(queryRequest: QueryRequest, bracketHasEnded: Bool) {
        self.queryRequest = queryRequest
        self.endLastBracket = bracketHasEnded
        list = [(.and, [.andWithBracket, .andWithoutBracket]),
                (.or, [.orWithBracket, .orWithoutBracket])]
        
        dummyStatement = Statement(aliasProperty: AliasProperty(alias: nil, propertyName: nil), argument: Argument.default, value: "...")
        if !bracketHasEnded && (queryRequest.wheres?.isLastClauseWrapWithBracket() ?? false || queryRequest.wheres?.getLast()?.isBracket() ?? false) {
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
        let cell = getTripleLinesTableViewCell(from: tableView, indexPath: indexPath)
        
        if let cell = cell as? TripleLinesTableViewCell {
            let option = list[indexPath.section].1[indexPath.row]
            cell.firstLabel.text = option.description
            
            cell.secondLabel.text = nil
            cell.secondLabel.numberOfLines = 1
            cell.secondLabel.lineBreakMode = .byTruncatingMiddle
            
            cell.thirdLabel.text = nil
            cell.thirdLabel.numberOfLines = 1
            let grayTextAttribute = [NSForegroundColorAttributeName : UIColor.gray]
            let boldFont = UIFont.boldSystemFont(ofSize: 12)
            
            if option == .endBracket, let count = queryRequest?.wheres?.getCount(), let display = WhereClause.getDisplayDescription(statement: queryRequest?.wheres?.getDescription(row: count - 1)) {
                let attributedText = NSMutableAttributedString(attributedString: display.prefix)
                attributedText.append(NSAttributedString(string: display.statement, attributes: grayTextAttribute))
                let suffix = NSMutableAttributedString(attributedString: display.suffix)
                suffix.addAttribute(NSFontAttributeName, value: boldFont, range: NSRange(location: 0, length: suffix.string.characters.count))
                attributedText.append(suffix)
                cell.secondLabel.attributedText = attributedText
            }
            else {
                let clauses = queryRequest.wheres?.insert(statement: dummyStatement, whereOption: option, endLastBracket: shouldEndLastBracket(option: option))
                let count = clauses?.getCount() ?? 0
                if count >= 2 {
                    
                    if let display = WhereClause.getDisplayDescription(statement: clauses?.getDescription(row: count - 2)) {
                        let attributed = NSMutableAttributedString(attributedString: display.prefix)
                        attributed.append(NSAttributedString(string: display.statement, attributes: grayTextAttribute))
                        attributed.append(display.suffix)
                        cell.secondLabel.attributedText = attributed
                    }
                    
                    if let display = WhereClause.getDisplayDescription(statement: clauses?.getDescription(row: count - 1)) {
                        let attributed = NSMutableAttributedString(attributedString: display.prefix)
                        attributed.addAttribute(NSFontAttributeName, value: boldFont, range: NSRange(location: 0, length: attributed.string.characters.count))
                        attributed.append(NSAttributedString(string: "...", attributes: grayTextAttribute))
                        let suffix = NSMutableAttributedString(attributedString: display.suffix)
                        if option.isBracket() {
                            suffix.addAttribute(NSFontAttributeName, value: boldFont, range: NSRange(location: 0, length: suffix.string.characters.count))
                        }
                        attributed.append(suffix)
                        cell.thirdLabel.attributedText = attributed
                    }
                }
            }
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return list[section].0.description
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let queryRequest = queryRequest else {
            return
        }
        var viewModel: GenericTableViewModel?
        let option = list[indexPath.section].1[indexPath.row]
        if option == .endBracket {
            viewModel = QueryWhereInitiate(queryRequest: queryRequest, bracketHasEnded: true)
        }
        else {
            viewModel = QueryWhere(queryRequest: queryRequest, action: .where, whereOption: option, endLastBracket: shouldEndLastBracket(option: option))
        }
        
        if let viewModel = viewModel,
            let vc = GenericTableViewController.getViewController(viewModel: viewModel) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func shouldEndLastBracket(option: WhereOptions) -> Bool {
        let isAndWithNewOr = (queryRequest?.wheres?.isAdd() ?? false) &&
            !(queryRequest?.wheres?.isLastClauseWrapWithBracket() ?? false) &&
            option.isOr()
        let isOrWithNewAnd = (queryRequest?.wheres?.isOr() ?? false) &&
            !(queryRequest?.wheres?.isLastClauseWrapWithBracket() ?? false) &&
            option.isAnd()
        return endLastBracket || isAndWithNewOr || isOrWithNewAnd
    }
}
