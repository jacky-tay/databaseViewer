//
//  DatabaseTables.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 30/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

class DatabaseTables {
    let databaseName: String!
    var tables: [String]!
    
    init(databaseName: String, tables: [String]) {
        self.databaseName = databaseName
        self.tables = tables
    }
}
