//
//  NSAttributeTypeExtension.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 17/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import CoreData
import Foundation

extension NSAttributeType: CustomStringConvertible {
    
    func getCategory() -> AttributeCategory {
        switch self {
        case .undefinedAttributeType:
            return .undefined
        case .stringAttributeType:
            return .text
        case .integer16AttributeType, .integer32AttributeType, .integer64AttributeType, .decimalAttributeType, .doubleAttributeType, .floatAttributeType:
            return .number
        case .dateAttributeType:
            return .date
        case .binaryDataAttributeType, .transformableAttributeType:
            return .binary
        case .objectIDAttributeType:
            return .objectId
        case .booleanAttributeType:
            return .boolean
        }
    }
    
    public func getKeyboardType() -> UIKeyboardType {
        switch self {
        case .integer16AttributeType, .integer32AttributeType, .integer64AttributeType:
            return .numberPad
        case .decimalAttributeType, .doubleAttributeType, .floatAttributeType:
            return .decimalPad
        case .dateAttributeType:
            return .default // TODO: datetime picker
        case .booleanAttributeType:
            return .default // TODO: boolean picker
        default:
            return .asciiCapable
        }

    }
    
    public var description: String {
        switch self {
        case .undefinedAttributeType:   return "Undefined"
        case .integer16AttributeType:   return "Int 16"
        case .integer32AttributeType:   return "Int 32"
        case .integer64AttributeType:   return "Int 64"
        case .decimalAttributeType:     return "Decimal"
        case .doubleAttributeType:      return "Double"
        case .floatAttributeType:       return "Float"
        case .stringAttributeType:      return "String"
        case .booleanAttributeType:     return "Boolean"
        case .dateAttributeType:        return "Date"
        case .binaryDataAttributeType:  return "Binary Data"
        case .objectIDAttributeType:    return "Object ID"
        default:                        return "Unknown"
        }
    }
}
