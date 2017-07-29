//
//  DatabaseTablesWithCount.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 30/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

class DatabaseTablesWithCount {
    let databaseName: String!
    let tables: [(name: String, count: Int)]
    
    init(databaseName: String, tables: [(name: String, count: Int)]) {
        self.databaseName = databaseName
        self.tables = tables
    }
}
