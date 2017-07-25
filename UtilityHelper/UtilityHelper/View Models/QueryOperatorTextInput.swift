//
//  QueryOperatorTextInput.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 24/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class QueryOperatorTextInput: NSObject, GenericTableViewModel {
    
    weak var navigationController: UINavigationController?
    weak var delegate: GenericTableViewModelDelegate?
    
    private weak var queryRequest: QueryRequest?
    internal var list = [String]()
    internal var filteredList = [Int]()
    private let alias: String!
    private let property: Property!
    private let whereArgument: WhereArgument!
    private var queryText: String? = nil
    private var queryDict = [Int : [NSRange]]()
    
    init(queryRequest: QueryRequest, alias: String, property: Property, whereArgument: WhereArgument) {
        self.queryRequest = queryRequest
        self.alias = alias
        self.property = property
        self.whereArgument = whereArgument
        if let databaseTable = queryRequest.getDatabaseTableAlias(from: alias) {
            self.list = DatabaseManager.sharedInstance.contextDict[databaseTable.databaseName]?.fetchValuesIn(for: databaseTable.tableName, key: property.name) ?? []
            self.filteredList = list.enumerated().map { $0.offset }
        }
    }
    
    func viewDidLoad(_ viewController: GenericTableViewController) {
        viewController.navigationItem.title = whereArgument.description
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : (queryText != nil ? filteredList.count : list.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0, let textFieldCell = getTextFieldCell(from: tableView, indexPath: indexPath) {
            textFieldCell.updateContent(attributeType: property.attributeType)
            textFieldCell.textField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
            return textFieldCell
        }
        let cell = getCell(from: tableView, indexPath: indexPath)
        if queryText != nil {
            let index = filteredList[indexPath.row]
            let attributedString = NSMutableAttributedString(string: list[index])
            if let ranges = queryDict[index] {
                ranges.forEach { attributedString.addAttributes([NSForegroundColorAttributeName : UIColor.red], range: $0) }
            }
            cell.textLabel?.attributedText = attributedString
        }
        else {
            cell.textLabel?.text = list[indexPath.row].description
        }
        cell.detailTextLabel?.text = nil
        cell.accessoryType = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextFieldTableViewCell)?.textField.text = list[filteredList[indexPath.row]]
            // TODO remove all other
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Or add from" : nil
    }
    
    dynamic private func textFieldDidChange(textField: UITextField) {
        guard let text = textField.text else {
            queryText = nil
            return
        }
        let previous = filteredList
        queryText = text
        filteredList = list.enumerated().flatMap { [weak self] item -> Int? in
            let ranges = item.element.getNSRanges(for: text)
            if !ranges.isEmpty {
                self?.queryDict[item.offset] = ranges
                return item.offset
            }
            return nil
        }
        
        delegate?.update(insertRows: [], insertSections: [1]) // TODO
    }
}
