//
//  WhereOptions.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 30/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

enum WhereCategory: CustomStringConvertible {
    case and
    case or
    case `default`
    
    var description: String {
        switch self {
        case .and:  return "AND"
        case .or:   return "OR"
        default:    return ""
        }
    }
}

enum WhereCategoryDisplay: CustomStringConvertible {
    case bracketStart(Int)
    case bracketEnd(Bool)
    case and(Int)
    case or(Int)
    
    var description: String {
        switch self {
        case .and:  return "AND "
        case .bracketEnd:   return ")"
        case .bracketStart: return "("
        case .or:   return "OR "
        }
    }
    
    func debugDesription() -> String {
        switch self {
        case .and(let v):  return "AND(\(v)) "
        case .bracketEnd(let v):   return ")(\(v))"
        case .bracketStart(let v): return "((\(v))"
        case .or(let v):   return "OR(\(v)) "
        }
    }
}

extension Array where Element == WhereCategoryDisplay {
    func update(to value: Int) -> [WhereCategoryDisplay] {
        var list = Array(self)
        let lastValue = list.removeLast()
        if case .and(_) = lastValue {
            list.append(.and(value))
        }
        else if case .or(_) = lastValue {
            list.append(.or(value))
        }
        else if case .bracketStart(_) = lastValue {
            list.append(.bracketStart(value))
        }
        return list
    }
}

func + (lhs: [WhereCategoryDisplay], rhs: WhereCategoryDisplay) -> [WhereCategoryDisplay] {
    var list = lhs
    list.append(rhs)
    return list
}

enum WhereOptions: CustomStringConvertible {
    case endBracket
    case andWithBracket
    case andWithoutBracket
    case orWithBracket
    case orWithoutBracket
    
    var description: String {
        switch self {
        case .endBracket:   return "Close previous bracket"
        case .andWithBracket:  return "AND with new bracket"
        case .andWithoutBracket:    return "AND without bracket"
        case .orWithBracket:   return "OR with new bracket"
        case .orWithoutBracket: return "OR without bracket"
        }
    }
    
    func isAnd() -> Bool {
        return [.andWithBracket, .andWithoutBracket].contains(self)
    }
    
    func isOr() -> Bool {
        return [.orWithBracket, .orWithoutBracket].contains(self)
    }
    
    func isBracket() -> Bool {
        return [.orWithBracket, .andWithBracket].contains(self)
    }
    
    func getCategory() -> WhereCategory {
        return isAnd() ? .and :
            isOr() ? .or : .default
    }
}
