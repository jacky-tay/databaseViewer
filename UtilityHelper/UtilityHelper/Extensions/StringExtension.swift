//
//  StringExtension.swift
//  DatabaseViewer
//
//  Created by Jacky Tay on 11/07/17.
//  Copyright © 2017 SmudgeApps. All rights reserved.
//

import UIKit
import CoreData

extension String {

    static func `is`(_ lhs: String?, smallerThan rhs: String?) -> Bool {
        guard let lhs = lhs, let rhs = rhs else {
            return false
        }
        return lhs < rhs
    }

    static func nilOrEmpty(_ string: String?) -> Bool {
        return string == nil || (string?.isEmpty ?? false)
    }
    
    func toNSAttributeType() -> NSAttributeType {
        let type = lowercased()
        let stringType = ["character", "varchar", "varying character", "nchar", "native character", "nvarchar", "text", "clob"]
        if stringType.first(where: { $0.contains(type) }) != nil {
            return .stringAttributeType
        }
        else if type.contains("decimal") {
            return .decimalAttributeType
        }

        switch self.lowercased() {

        case "double":
            return .doubleAttributeType
        case "float", "real":
            return .floatAttributeType
        case "blob":
            return .binaryDataAttributeType
        case "boolean":
            return .booleanAttributeType
        case "date", "datetime":
            return .dateAttributeType
        default:
            return .undefinedAttributeType
        }
    }

    func joined(contentsOf: [String?]) -> String {
        return contentsOf.flatMap { String.nilOrEmpty($0) ? nil : $0 }.joined(separator: self)
    }
    
    func buildAliasName() -> String {
        guard !contains("_") else {
            return "".joined(contentsOf: components(separatedBy: "_").map { $0.characters.first?.toString() })
        }
        let uppercase = CharacterSet.uppercaseLetters
        return unicodeScalars.flatMap { uppercase.contains($0) ? String(Character($0)) : nil }.reduce("", +)
    }

    func calculateFrameSize(width: CGFloat = CGFloat.greatestFiniteMagnitude, height: CGFloat = CGFloat.greatestFiniteMagnitude, font: UIFont) -> CGSize {
        return self.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading, .truncatesLastVisibleLine], attributes: [NSFontAttributeName: font], context: nil).size
    }
    
    func toAttributedString(highlights: [String : UIColor]) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: self)
        for highlight in highlights {
            let ranges = getNSRanges(for: highlight.key)
            for _range in ranges {
                attributed.addAttribute(NSForegroundColorAttributeName, value: highlight.value, range: _range)
            }
        }
        return attributed
    }
    
    func getNSRanges(for query: String?) -> [NSRange] {
        guard let query = query else {
            return []
        }
        
        var searchRanges = [NSRange]()
        let len = characters.count
        var range = NSMakeRange(0, len)
        while range.location != NSNotFound {
            range = NSString(string: self).range(of: query, options: .caseInsensitive, range: range)
            if range.location != NSNotFound {
                searchRanges.append(range)
                let location = range.length + range.location
                range = NSMakeRange(location, len - location)
            }
        } // while
        return searchRanges
    }
}
