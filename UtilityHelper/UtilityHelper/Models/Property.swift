//
//  Property.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 29/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import CoreData
import Foundation

class Property {
    let name: String!
    let attributeType: NSAttributeType!
    
    init(name: String, attributeType: NSAttributeType) {
        self.name = name
        self.attributeType = attributeType
    }
}
