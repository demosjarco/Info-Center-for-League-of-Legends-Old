//
//  StretchyHeaderCollectionViewLayout.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/30/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class StretchyHeaderCollectionViewLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // This will schedule calls to layoutAttributesForElementsInRect: as the collectionView is scrolling.
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let collectionView = self.collectionView
        let insets = collectionView!.contentInset
        let offset = collectionView!.contentOffset
        let minY = CGFloat(fabsf(Float(insets.top)) * -1)
        
        // First get the superclass attributes.
        let attributes = super.layoutAttributesForElements(in: rect)
        
        // Check if we've pulled below past the lowest position
        if offset.y < minY {
            // Figure out how much we've pulled down
            let deltaY = CGFloat(fabsf(Float(offset.y - minY)))
            
            for attrs in attributes! {
                // Locate the header attributes
                let kind = attrs.representedElementKind
                if kind == UICollectionElementKindSectionHeader {
                    // Adjust the header's height and y based on how much the user has pulled down.
                    let headerSize = self.headerReferenceSize
                    var headerRect = attrs.frame
                    headerRect.size.height = max(minY, headerSize.height + deltaY)
                    headerRect.origin.y -= deltaY
                    attrs.frame = headerRect
                    break
                }
            }
        }
        return attributes
    }
}
