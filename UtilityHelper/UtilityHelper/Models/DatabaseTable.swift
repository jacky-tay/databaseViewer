//
//  DatabaseTable.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 30/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

class DatabaseTable: Hashable {
    let databaseName: String!
    let tableName: String!
    
    init(databaseName: String, tableName: String) {
        self.databaseName = databaseName
        self.tableName = tableName
    }
    
    var hashValue: Int {
        return databaseName.hashValue ^ tableName.hashValue &* 16777619
    }
    
    static func == (lhs: DatabaseTable, rhs: DatabaseTable) -> Bool {
        return lhs.databaseName == rhs.databaseName &&
            lhs.tableName == rhs.tableName
    }
}
