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
    case bracketEnd(Int)
    case and(Int, Int)
    case or(Int, Int)
    
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
        case .and(let v, let c):  return "AND.\(v).\(c)"
        case .bracketEnd(let v):   return ").\(v)"
        case .bracketStart(let v): return "(.\(v)"
        case .or(let v, let c):   return "OR.\(v)\(c)"
        }
    }
    
    func getBracketIndex() -> Int? {
        switch self {
        case .bracketStart(let v), .bracketEnd(let v):    return v
        default:    return nil
        }
    }
    
    func getAndOrIndexCount() -> (index: Int, count: Int)? {
        switch self {
        case .and(let i, let c), .or(let i, let c):    return (i, c)
        default:    return nil
        }
    }
}

extension Array where Element == WhereCategoryDisplay {
    
    func update(to value: Int) -> [WhereCategoryDisplay] {
        var list = Array(self)
        guard !list.isEmpty else {
            return list
        }
        
        let lastValue = list.removeLast()
        if case .and(_ ,let count) = lastValue {
            list.append(.and(value, count))
        }
        else if case .or(_, let count) = lastValue {
            list.append(.or(value, count))
        }
        else if case .bracketStart(_) = lastValue {
            list.append(.bracketStart(value))
        }
        else if case .bracketEnd(_) = lastValue {
            list.append(.bracketEnd(value))
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
