//
//  OrderBy.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 20/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

enum OrderBy: CustomStringConvertible {
    case asc
    case desc
    
    var description: String {
        return self == .asc ? "ASC" : "DESC"
    }
}
