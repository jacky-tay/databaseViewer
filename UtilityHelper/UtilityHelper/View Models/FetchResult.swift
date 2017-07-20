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
    func processData(for entityName: String, results: [String : Any], table: Table, displayFields: [String]) {
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
    }
}
