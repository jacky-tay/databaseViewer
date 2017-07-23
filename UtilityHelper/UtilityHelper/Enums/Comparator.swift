//
//  Comparator.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 20/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

protocol WhereArgument: CustomStringConvertible { }

enum Comparator: WhereArgument {
    case equal
    case greaterThan
    case lessThan
    case greaterThanEqual
    case lessThanEqual
    case notEqual
    
    var description: String {
        switch self {
        case .equal:        return "="
        case .greaterThan:  return ">"
        case .lessThan:     return "<"
        case .greaterThanEqual: return ">="
        case .lessThanEqual:    return "<="
        case .notEqual:         return "<>"
        }
    }
    
    static func getAll(filterBy: AttributedCategory?) -> [Comparator] {
        guard let filter = filterBy else {
            return [.equal, .greaterThan, .lessThan, .greaterThanEqual, .lessThanEqual, .notEqual]
        }
        
        switch filter {
        case .text, .objectId, .boolean, .binary:
            return [.equal, .notEqual]
        default:
            return [.equal, .greaterThan, .lessThan, .greaterThanEqual, .lessThanEqual, .notEqual]
        }
    }
}
