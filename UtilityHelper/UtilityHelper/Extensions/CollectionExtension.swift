//
//  CollectionExtension.swift
//  DatabaseViewer
//
//  Created by Jacky Tay on 14/07/17.
//  Copyright © 2017 SmudgeApps. All rights reserved.
//

import Foundation

public extension Collection {
    public func toDictionary<K: Hashable, V>(key: (Iterator.Element) -> K?, value: (Iterator.Element) -> V?) -> [K: V] {
        var dict = [K:V]()
        forEach {
            if let _key = key($0), let _value = value($0) {
                dict[_key] = _value
            }
        }
        return dict
    }
}
