//
//  DuplexCollectionViewLayout.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 17/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import UIKit

class DuplexCollectionViewLayout: UICollectionViewLayout {
    private var contentSize = CGSize.zero
    private var itemAttributes: [[UICollectionViewLayoutAttributes]] = []
    var columnSizes: [CGSize] = []

    override func prepare() {
        if itemAttributes.isEmpty {
            initiateContentItemsAttribute()
        }
        else {
            lockFirstRowAndColumn()
        }
    }

    private func initiateContentItemsAttribute() {
        guard let collectionView = collectionView, collectionView.numberOfSections > 0, !columnSizes.isEmpty else {
            return
        }

        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0

        for section in 0 ..< collectionView.numberOfSections {
            xOffset = 0
            var itemSize = columnSizes[0]
            var list = [UICollectionViewLayoutAttributes]()
            for row in 0 ..< columnSizes.count {
                itemSize = columnSizes[row]
                let indexPath = IndexPath(row: row, section: section)
                let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attribute.frame = CGRect(origin: CGPoint(x: xOffset, y: yOffset), size: itemSize)

                if section == 0 && row == 0 {
                    attribute.zIndex = 1024
                }
                else if section == 0 || row == 0 {
                    attribute.zIndex = 1023
                }

                if section == 0 {
                    attribute.updateOriginY(collectionView.contentOffset.y)
                }
                if row == 0 {
                    attribute.updateOriginX(collectionView.contentOffset.x)
                }
                list.append(attribute)

                xOffset += itemSize.width
            } // row
            itemAttributes.append(list)
            yOffset += itemSize.height
        } // section

        if let attributeFrame = itemAttributes.last?.last?.frame {
            contentSize = CGSize(width: attributeFrame.width + attributeFrame.origin.x, height: attributeFrame.height + attributeFrame.origin.y)
        }
    }

    private func lockFirstRowAndColumn() {
        guard let collectionView = collectionView else {
            return
        }
        for section in 0 ..< collectionView.numberOfSections {
            for row in 0 ..< collectionView.numberOfItems(inSection: section) {
                if section != 0 && row != 0 {
                    continue
                }
                if section == 0 || row == 0, let attribute = layoutAttributesForItem(at: IndexPath(row: row, section: section)) {

                    if section == 0 {
                        attribute.updateOriginY(collectionView.contentOffset.y)
                    }

                    if row == 0 {
                        attribute.updateOriginX(collectionView.contentOffset.x)
                    }
                }
            } // row
        } // section
    }

    override var collectionViewContentSize: CGSize {
        return contentSize
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemAttributes.count > indexPath.section && itemAttributes[indexPath.section].count > indexPath.row ? itemAttributes[indexPath.section][indexPath.row] : nil
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return itemAttributes.flatMap { $0.filter { (item) in item.frame.intersects(rect) } }
    }

}
