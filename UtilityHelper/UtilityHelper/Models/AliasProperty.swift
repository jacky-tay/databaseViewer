//
//  AliasProperty.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 30/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

class AliasProperty: CustomStringConvertible {
    var alias: String?
    let propertyName: String?
    
    var description: String {
        return ".".joined(contentsOf: [alias, propertyName])
    }
    
    init(alias: String?, propertyName: String?) {
        self.alias = alias
        self.propertyName = propertyName
    }
}
