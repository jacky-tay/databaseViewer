//
//  Aggregate.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 22/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

enum Aggregate: CustomStringConvertible {
    case average
    case count
    case maximum
    case minimum
    case sum
    
    var description: String {
        switch self {
        case .average: return "Avg"
        case .count: return "Count"
        case .maximum:   return "Max"
        case .minimum:   return "Min"
        case .sum:   return "Sum"
        }
    }
}
