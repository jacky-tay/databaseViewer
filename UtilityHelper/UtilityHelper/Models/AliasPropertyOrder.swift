//
//  AliasPropertyOrder.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 30/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

class AliasPropertyOrder: AliasProperty, Hashable {
    var order = OrderBy.asc
    
    var hashValue: Int {
        let aHash = alias?.hashValue ?? 7
        let pHash = propertyName?.hashValue ?? 13
        let oHash = order.description.hashValue
        return aHash ^ pHash ^ oHash
    }
    
    public static func == (lhs: AliasPropertyOrder, rhs: AliasPropertyOrder) -> Bool {
        return lhs.alias == rhs.alias && lhs.alias != nil &&
            lhs.propertyName == rhs.propertyName && lhs.propertyName != nil &&
            lhs.order == rhs.order
    }
    
    init(alias: String?, propertyName: String, order: OrderBy) {
        self.order = order
        super.init(alias: alias, propertyName: propertyName)
    }
    
    func getAttributedString() -> NSAttributedString {
        return NSMutableAttributedString.build(from: [(description, nil),
                                                      (" ", nil),
                                                      (order.description, MaterialColor.blue)])
    }
    
    func toggleOrder() {
        if order == .desc {
            order = .asc
        }
        else {
            order = .desc
        }
    }
}
