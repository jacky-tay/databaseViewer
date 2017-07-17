//
//  DisplayResult.swift
//  DatabaseViewer
//
//  Created by Jacky Tay on 14/07/17.
//  Copyright © 2017 SmudgeApps. All rights reserved.
//

import UIKit

class DisplayResult {
    let title: [String]!
    let contents: [[String?]]!
    var columnWidth: [CGFloat]!

    static var maxWidth: CGFloat = 300
    static var displayHeight: CGFloat = 44
    static let displayHeaderFont = UIFont(name: "Courier-Bold", size: 17) ?? UIFont.monospacedDigitSystemFont(ofSize: 15, weight: UIFontWeightBold)
    static let displayFont = UIFont(name: "Courier", size: 17) ?? UIFont.monospacedDigitSystemFont(ofSize: 17, weight: UIFontWeightRegular)
    static let margin: CGFloat = 20

    static func prepare(title: [String], contents: [[String?]], completionHandler: @escaping ()->()) -> DisplayResult? {
        // ensure the contents column count is same as title count
        guard (contents.reduce(true) { $0 && $1.count == title.count }) else {
            return nil
        }

        let displayResult = DisplayResult(title: title, contents: contents)
        
        DispatchQueue.global().async {
            displayResult.prepareColumnSize()
            completionHandler()
        }
        return displayResult
    }

    private init(title: [String], contents: [[String?]]) {
        self.title = title
        self.contents = contents
    }

    private func prepareColumnSize() {
        columnWidth = [CGFloat]()
        let font = DisplayResult.displayFont
        let width = DisplayResult.maxWidth
        let margin = DisplayResult.margin
        columnWidth.append(ceil(String(contents.count + 1).calculateFrameSize(width: width, font: font).width * 1.05) + margin)

        for column in 0 ..< title.count {
            var longestText = title[column]
            for row in contents {
                if let value = row[column], longestText.characters.count < value.characters.count {
                    longestText = value
                }
            }
            columnWidth.append(ceil(longestText.calculateFrameSize(width: width, font: font).width * 1.05) + margin)
        }
    }
}
