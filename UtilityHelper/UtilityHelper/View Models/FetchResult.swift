//
//  FetchResult.swift
//  DatabaseViewer
//
//  Created by Jacky Tay on 14/07/17.
//  Copyright © 2017 SmudgeApps. All rights reserved.
//

import Foundation
import CoreData

class FetchResult {
    
    static func executeAndProcess(aliasTable: DatabaseAliasTable, selected: [AliasProperty], whereClause: WhereClause?, groupBy: [AliasProperty], orderBy: [AliasPropertyOrder]) -> [String : [[String : Any]]] {
        guard let context = DatabaseManager.sharedInstance.contextDict[aliasTable.databaseName],
            let alias = aliasTable.alias else {
            return [:]
        }
        
        let predicate = whereClause?.toNSPredicate(filterBy: alias)
        print("predicate", alias, predicate?.description ?? "-")
        var keys = selected.flatMap { $0.alias == alias ? $0.propertyName : nil }
        keys.append(contentsOf: groupBy.flatMap { $0.alias == alias ? $0.propertyName : nil })
        keys.append(contentsOf: orderBy.flatMap { $0.alias == alias ? $0.propertyName : nil })
        if let propertyNames = whereClause?.getPropertyNames(filterBy: alias) {
            keys.append(contentsOf: propertyNames.flatMap { $0 })
        }
        
        let results = context.fetch(for: aliasTable.tableName, predicate: predicate, keys: keys.distinct())
        print(results.count)
        return [alias : results]
    }
    
    static func mergeData(queryResult: QueryRequest, results: [String : [[String : Any]]], completionHandler: @escaping () -> ()) {
        var indexPointers = [String : Int]()
        var row = [String?]()
        var contents = [[String?]]()
        for column in queryResult.selected {
            if let alias = column.alias, let propertyName = column.propertyName {
                let index = indexPointers[alias] ?? 0
                let table = results[alias]
                let resultRow = table?[index]
                let value = resultRow?[propertyName] as? AnyObject
                row.append(value?.description)
            }
        }
        contents.append(row)
        _ = DisplayResult.prepare(titles: [], contents: contents, completionHandler: completionHandler)
    }
    
    /*func processData(for entityName: String, results: [String : Any], table: Table, displayFields: [String]) {
        var results = [String : Any]()
        for field in displayFields {
            results[field] = process(field: field, attributedType: table.properties.first { $0.name == field }?.attributeType, value: results[field])
        }
    }

    func process(field: String, attributedType: NSAttributeType?, value: Any?) -> Any? {

        guard let attributedType = attributedType, let value = value else {
            return nil
        }

        switch attributedType {
        case .integer16AttributeType, .integer32AttributeType, .integer64AttributeType, .decimalAttributeType, .doubleAttributeType, .floatAttributeType:
            _ = value as? NSNumber
            break
        case .stringAttributeType:
            _ = value as? String
            break
        case .booleanAttributeType:
            _ = value as? Bool
            break
        case .dateAttributeType:
            _ = value as? Date
            break
        case .binaryDataAttributeType:
            break
        case .transformableAttributeType:
            break
        case .objectIDAttributeType:
            break
        default:
            break
        }
        return nil
    }*/
}
