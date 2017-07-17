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
    public var description: String {
        switch self {
        case .undefinedAttributeType:   return "Undefined"
        case .integer16AttributeType:   return "Int 16"
        case .integer32AttributeType:   return "Int 32"
        case .integer64AttributeType:   return "Int 64"
        case .decimalAttributeType:     return"Decimal"
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
