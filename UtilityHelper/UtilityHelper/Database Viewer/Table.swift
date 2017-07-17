//
//  Table.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 17/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import CoreData
import Foundation

class Table {
    let name: String
    let alias: String
    var count: Int = 0
    let propertiesName: [String]
    let properties: [String : NSAttributeType]
    let relationships: [String]?

    init(name: String, properties: [String : NSAttributeType], relationships: [String]? = nil) {
        self.name = name
        alias = name.takeUppercasedCharacter()
        propertiesName = Array(properties.keys).sorted()
        self.properties = properties
        self.relationships = relationships?.sorted()
    }
}
