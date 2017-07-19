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
    var from: DatabaseTablePair!
    
    init(from: DatabaseTablePair) {
        self.from = from
    }
    
    func getRowCount(for section: Int) -> Int {
        return section == 1 ? selected.count : 1
    }
    
    func getSectionCount() -> Int {
        return 2
    }
    
    func getSectionTitle(section: Int) -> String {
        return section == 0 ? "Select" :
        section == 1 ? "From" : ""
    }
    
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
