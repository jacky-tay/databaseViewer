//
//  WhereOptions.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 30/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

enum WhereOptions: CustomStringConvertible {
    case startWithBracket
    case startWithoutBracket
    case endBracket
    case and
    case or
    
    var description: String {
        switch self {
        case .startWithBracket: return "Start with new bracket"
        case .startWithoutBracket:  return "Start without bracket"
        case .endBracket:   return "Close previous bracket"
        case .and:  return "AND"
        case .or:   return "OR"
        }
    }
}
