//
//  QueryRequestModel.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 18/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

class QueryRequestModel: QueryActionDelegate {
    var selected = [String]()
    var from: String?
    
    // MARK: - QueryActionDelegate
    func didSelect(properties: [(TablePropertyPair)]) {
        
    }
    
    func didOrderBy(properties: [(TablePropertyPair)]) {
        
    }
    
    func didGroupBy(properties: [(TablePropertyPair)]) {
        
    }
    
    func addRelationship(between left: DatabaseTablePair, and right: DatabaseTablePair, joinType: Join) {
        
    }
}
