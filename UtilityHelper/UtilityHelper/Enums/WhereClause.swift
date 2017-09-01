//
//  WhereClause.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 29/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

typealias WhereClauseStatement = (prefix: [WhereCategoryDisplay], statement: String, suffix: [WhereCategoryDisplay])

indirect enum WhereClause {
    case and([WhereClause])
    case or([WhereClause])
    case bracket(WhereClause)
    case base(Statement)
    
    static func canAppend(lhs: WhereClause, rhs: WhereClause) -> Bool {
        switch (lhs, rhs) {
        case (.and, .base), (.and, .bracket), (.or, .base), (.or, .bracket):
            return true
        case (.bracket, base), (.bracket, .and), (.bracket, .or):
            return true
        default:
            return false
        }
    }
    
    static func shouldInsert(lhs: WhereClause, rhs: WhereClause) -> Bool {
        switch (lhs, rhs) {
        case (.base, .and), (.bracket, .and), (.base, .or), (.bracket, .or):
            return true
        default:
            return false
        }
    }
    
    func isBase() -> Bool {
        if case .base(_) = self {
            return true
        }
        return false
    }
    
    func isAdd() -> Bool {
        if case .and(_) = self {
            return true
        }
        return false
    }
    
    func isOr() -> Bool {
        if case .or(_) = self {
            return true
        }
        return false
    }
    
    func isBracket() -> Bool {
        if case .bracket(_) = self {
            return true
        }
        return false
    }
    
    func getLast() -> WhereClause? {
        return getLast(ancestor: []).last
    }
    
    private func getLast(ancestor: [WhereClause]) -> [WhereClause] {
        if case .and(let list) = self {
            return list.last?.getLast(ancestor: ancestor + self) ?? ancestor
        }
        else if case .or(let list) = self {
            return list.last?.getLast(ancestor: ancestor + self) ?? ancestor
        }
        else if case .bracket(let clause) = self {
            return clause.getLast(ancestor: ancestor + self)
        }
        return ancestor + self
    }
    
    func isLastClauseWrapWithBracket() -> Bool {
        let root = getLast(ancestor: [])
        if root.count > 2 {
            let lastIndex = root.count - 1
            return root[lastIndex - 1].isBracket() ||
                    ((root[lastIndex - 1].isOr() || root[lastIndex - 1].isAdd()) && root[lastIndex - 2].isBracket())
        }
        else if root.count > 1 {
            return root[0].isBracket()
        }
        return false
    }
    
    func getDescription(row: Int, prefix: [WhereCategoryDisplay] = [], suffix: [WhereCategoryDisplay] = [], isLast: Bool = false) -> WhereClauseStatement? {
        if case .base(let statement) = self {
            return (prefix, statement.description, suffix)
        }
        else if case .and(let list) = self {
            return getDescription(row: row, prefix: prefix + WhereCategoryDisplay.and(0, list.count), suffix: suffix, list: list)
        }
        else if case .or(let list) = self {
            return getDescription(row: row, prefix: prefix + WhereCategoryDisplay.or(0, list.count), suffix: suffix, list: list)
        }
        else if case .bracket(let clause) = self {
            return clause.getDescription(row: row, prefix: prefix + WhereCategoryDisplay.bracketStart(row), suffix: suffix + WhereCategoryDisplay.bracketEnd(row))
        }
        return nil
    }
    
    static func getDisplayDescription(statement: WhereClauseStatement?, highlightColor: Bool = false) -> (prefix: NSAttributedString, statement: String, suffix: NSAttributedString)? {
        
        guard let statement = statement else {
            return nil
        }
        let prefixString = NSMutableAttributedString()
        var preList = [WhereCategoryDisplay]()
        
        for pre in statement.prefix.enumerated() {
            var show = false
            if let andOr = pre.element.getAndOrIndexCount() {
                show = andOr.index != 0
                if show && pre.offset + 1 < statement.prefix.count, let bracket = statement.prefix[pre.offset + 1].getBracketIndex() {
                    show = bracket == 0
                }
                preList = preList.update(to: (andOr.index - andOr.count))
            }
            else if let bracket = pre.element.getBracketIndex() {
                show = bracket == 0
                preList.append(.bracketStart(-1))
            }
            let color = show ? pre.element.getColor(highlightColor: highlightColor) : UIColor.clear
            prefixString.append(NSAttributedString(string: pre.element.description, attributes: [NSForegroundColorAttributeName : color]))
        }
        
        preList = preList.reversed()
        let suffixString = NSMutableAttributedString()
        for pre in preList.enumerated() {
            var show = true
            
            if let preIndex = pre.element.getBracketIndex() {
                let suffix = preList.prefix(pre.offset)
                for s in suffix {
                    if let bracket = s.getBracketIndex(), bracket != -1 {
                        show = false
                    }
                }
                show = show && preIndex == -1
            }
            let color = show ? UIColor.darkText : UIColor.clear
            suffixString.append(NSAttributedString(string: ")", attributes: [NSForegroundColorAttributeName : color]))
        }
        return (prefixString, statement.statement, suffixString)
    }
    
    private func getDescription(row: Int, prefix: [WhereCategoryDisplay], suffix: [WhereCategoryDisplay], list: [WhereClause]) -> WhereClauseStatement? {
        var count = 0
        var index = -1
        repeat {
            index += 1
            count += list[index].getCount()
        } while index + 1 < list.count && row >= count
        let rowInArray = row - count + list[index].getCount()
        let useIndex = list[index].isBase() || list[index].isBracket()
        return list[index].getDescription(row: rowInArray,
                                          prefix: prefix.update(to: useIndex ? index : rowInArray),
                                          suffix: suffix.update(to: useIndex ? index : rowInArray),
                                          isLast: index + 1 == list.count)
    }
    
    func insert(statement: Statement, whereOption: WhereOptions?, endLastBracket: Bool?) -> WhereClause {
        guard let whereOption = whereOption, let endLastBracket = endLastBracket else {
            return .base(statement)
        }
        let clause: WhereClause = whereOption.isBracket() ? .bracket(.base(statement)) : .base(statement)
        return clause.update(whereClause: self, with: whereOption.getCategory(), endLastBracket: endLastBracket)
    }
    
    
    func update(whereClause: WhereClause?, with category: WhereCategory, endLastBracket: Bool) -> WhereClause {
        guard let whereClause = whereClause else {
            return self
        }
        // TODO: ????
        if case .bracket(let clause) = whereClause {
            return .bracket(update(whereClause: clause, with: category, endLastBracket: endLastBracket))
        }
        else if whereClause.isBase() && category == .and {
            return .and([whereClause, self])
        }
        else if whereClause.isBase() && category == .or {
            return .or([whereClause, self])
        }
        else if endLastBracket && whereClause.isAdd() && category == .or {
            return .or([.bracket(whereClause), self])
        }
        else if endLastBracket && whereClause.isOr() && category == .and {
            return .and([.bracket(whereClause), self])
        }
        else if case .and(let list) = whereClause {
            var _list = list
            if category == .and && (endLastBracket || list.last?.isBase() ?? false) {
                _list.append(self)
            }
            else {
                let last = _list.removeLast()
                _list.append(update(whereClause: last, with: category, endLastBracket: endLastBracket))
            }
            return .and(_list)
        }
        else if case .or(let list) = whereClause {
            var _list = list
            if category == .or && (endLastBracket || list.last?.isBase() ?? false) {
                _list.append(self)
            }
            else {
                let last = _list.removeLast()
                _list.append(update(whereClause: last, with: category, endLastBracket: endLastBracket))
            }
            return .or(_list)
        }
        return self
    }
    
    func getCount() -> Int {
        if case .and(let list) = self {
            return list.reduce(0) { $0 + $1.getCount() }
        }
        else if case .or(let list) = self {
            return list.reduce(0) { $0 + $1.getCount() }
        }
        else if case .bracket(let clause) = self {
            return clause.getCount()
        }
        else if case .base = self {
            return 1
        }
        return 0
    }
}

func + (lhs: [WhereClause], rhs: WhereClause) -> [WhereClause] {
    var list = lhs
    list.append(rhs)
    return list
}
