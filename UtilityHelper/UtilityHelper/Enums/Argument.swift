//
//  Argument.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 23/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

enum Argument: WhereArgument {
    case `in`
    case isNull
    case isNotNull
    case between
    case like
    case `default`
    
    var description: String {
        switch self {
        case .in:       return "IN"
        case .isNull:   return "IS NULL"
        case .isNotNull:    return "IS NOT NULL"
        case .between:  return "BETWEEN"
        case .like:     return "LIKE"
        case .default:  return ""
        }
    }
    
    func showDisclosureIndicator() -> Bool {
        switch self {
        case .isNull, .isNotNull:
            return false
        default:
            return true
        }
    }
    
    static func getAll(filterBy: AttributeCategory?) -> [Argument] {
        guard let filter = filterBy else {
            return [.in, .isNull, .isNotNull, .between, .like]
        }
        
        switch filter {
        case .text:
            return [.in, .isNull, .isNotNull, .like]
        case .objectId, .boolean, .binary:
            return [.in, .isNull, .isNotNull]
        default:
            return [.in, .isNull, .isNotNull, .between]
        }
    }
}
