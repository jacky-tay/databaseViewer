//
//  JoinWithDatabaseAliasTable.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 30/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

class JoinWithDatabaseAliasTable {
    var propertyName: String?
    var comparator: Comparator?
    var otherTableProperty: String?
    
    init() {
        
    }
    
    init(propertyName: String, comparator: Comparator, otherProperty: String) {
        self.propertyName = propertyName
        self.comparator = comparator
        self.otherTableProperty = otherProperty
    }
}
