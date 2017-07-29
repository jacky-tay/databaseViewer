//
//  DatabaseTableProperty.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 30/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

class DatabaseTableProperty: DatabaseTable {
    let propertyName: String!
    
    init(databaseName: String, tableName: String, propertyName: String) {
        self.propertyName = propertyName
        super.init(databaseName: databaseName, tableName: tableName)
    }
}
