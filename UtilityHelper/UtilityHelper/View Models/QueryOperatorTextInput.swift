//
//  QueryOperatorTextInput.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 24/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class QueryOperatorTextInput: NSObject, GenericTableViewModel, UITextFieldDelegate {
    
    weak var navigationController: UINavigationController?
    weak var delegate: GenericTableViewModelDelegate?
    
    internal weak var queryRequest: QueryRequest?
    internal var list = [String]()
    internal var filteredList = [Int]()
    internal var aliasProperty: AliasProperty!
    internal var whereArgument: WhereArgument!
    private var queryText: String? = nil
    private var queryDict = [Int : [NSRange]]()
    
    init(queryRequest: QueryRequest, aliasProperty: AliasProperty, whereArgument: WhereArgument) {
        self.queryRequest = queryRequest
        self.aliasProperty = aliasProperty
        self.whereArgument = whereArgument
    }
    
    func setupContent() {
        if let alias = aliasProperty.alias,
            let propertyName = aliasProperty.propertyName,
            let databaseTable = queryRequest?.getDatabaseAliasTable(from: alias) {
            self.list = DatabaseManager.sharedInstance.contextDict[databaseTable.databaseName]?.fetchValuesIn(for: databaseTable.tableName, key: propertyName) ?? []
            self.filteredList = list.enumerated().map { $0.offset }
        }
    }
    
    func viewDidLoad(_ viewController: GenericTableViewController) {
        viewController.navigationItem.title = whereArgument.description
        addDoneOnRightHandSide(viewController)
        setupContent()
    }
    
    func doneIsClicked() {
        if let cell = delegate?.getCellRow(at: IndexPath(row: 0, section: 0)) as? TextFieldTableViewCell,
            let text = cell.textField.text {
            let statement = Statement(aliasProperty: aliasProperty, argument: whereArgument, values: [text])
            // TODO
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.isEmpty ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : (queryText != nil ? filteredList.count : list.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0,
            let property = queryRequest?.getProperty(from: aliasProperty),
            let textFieldCell = getTextFieldCell(from: tableView, indexPath: indexPath) {
            textFieldCell.updateContent(attributeType: property.attributeType)
            textFieldCell.textField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
            textFieldCell.textField.delegate = self
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
        return section == 1 && !list.isEmpty ? "Or add from" : nil
    }
    
    dynamic private func textFieldDidChange(textField: UITextField) {

        let previous = filteredList

        if let text = textField.text, !text.isEmpty {
            queryText = text
            filteredList = list.enumerated().flatMap { [weak self] item -> Int? in
                let ranges = item.element.getNSRanges(for: text)
                if !ranges.isEmpty {
                    self?.queryDict[item.offset] = ranges
                    return item.offset
                }
                return nil
            } // flatMap
        }
        else {
            queryText = nil
            filteredList = list.enumerated().map { $0.offset }
        }

        let diff = previous.difference(from: filteredList)
        delegate?.animateTable(in: 1, reloadRows: diff.unchanged, insertRows: diff.inserted, deleteRows: diff.deleted)
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
