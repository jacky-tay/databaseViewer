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

    func takeUppercasedCharacter() -> String {
        let uppercase = CharacterSet.uppercaseLetters
        return unicodeScalars.flatMap { uppercase.contains($0) ? String(Character($0)) : nil }.reduce("", +)
    }

    func calculateFrameSize(width: CGFloat = CGFloat.greatestFiniteMagnitude, height: CGFloat = CGFloat.greatestFiniteMagnitude, font: UIFont) -> CGSize {
        return self.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading, .truncatesLastVisibleLine], attributes: [NSFontAttributeName: font], context: nil).size
    }
}
