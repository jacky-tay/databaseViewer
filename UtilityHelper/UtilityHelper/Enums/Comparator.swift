//
//  Comparator.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 20/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

enum Comparator: String {
    case equal = "="
    case greaterThan = ">"
    case lessThan = "<"
    case greaterThanEqual = ">="
    case lessThanEqual = "<="
    case notEqual = "<>"
    
    static func getAll(filterBy: AttributedCategory? = nil) -> [Comparator] {
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
