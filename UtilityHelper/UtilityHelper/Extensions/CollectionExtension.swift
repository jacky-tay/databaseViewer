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

public extension Array {
    
    public func toString(separator: String = " ") -> String {
        return self.map { ($0 as AnyObject).description }.joined(separator: separator)
    }
 
    public func distinct<T : Equatable>() -> [T] {
        guard let equatableList = self as? [T] else {
            return []
        }
        var result = [T]()
        for item in equatableList where !result.contains(item) {
            result.append(item)
        }
        return result
    }

    public func difference<T : Equatable>(from array: [T]) -> (unchanged: [Int], inserted: [Int], deleted: [Int]) {
        guard let list = self as? [T] else {
            return ([], [], [])
        }
        let unchanged = list.enumerated().flatMap { array.contains($0.element) ? $0.offset : nil }
        let deleted = list.enumerated().flatMap { !array.contains($0.element) ? $0.offset : nil }
        let inserted = array.enumerated().flatMap { !list.contains($0.element) ? $0.offset : nil }
        return (unchanged, inserted, deleted)
    }
}
