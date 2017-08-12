//
//  WhereOptions.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 30/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

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
}
