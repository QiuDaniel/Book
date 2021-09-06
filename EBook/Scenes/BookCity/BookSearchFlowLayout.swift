//
//  BookSearchFlowLayout.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/5.
//

import UIKit

class BookSearchFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attrs = super.layoutAttributesForElements(in: rect) else { return nil }
        var tmpAttrs: [UICollectionViewLayoutAttributes] = []
        for (idx, attr) in attrs.enumerated() {
            let previousArr = idx == 0 ? nil: attrs[idx - 1]
            let nextAttr = idx + 1 == attrs.count ? nil: attrs[idx + 1]
            tmpAttrs.append(attr)
            let previousY = previousArr == nil ? 0 : previousArr?.frame.maxY
            let currentY = attr.frame.maxY
            let nextY = nextAttr == nil ? 0 : nextAttr?.frame.maxY
            if currentY != previousY && currentY != nextY {
                if attr.representedElementKind == UICollectionView.elementKindSectionHeader {
                    tmpAttrs.removeAll()
                } else if attr.representedElementKind == UICollectionView.elementKindSectionFooter {
                    tmpAttrs.removeAll()
                } else {
                    changeCellFrame(withLayoutAttributes: tmpAttrs)
                    tmpAttrs.removeAll()
                }
            } else if currentY != nextY {
                changeCellFrame(withLayoutAttributes: tmpAttrs)
                tmpAttrs.removeAll()
            }
        }
        return attrs
    }
}

private extension BookSearchFlowLayout {
    func changeCellFrame(withLayoutAttributes layoutAttributes: [UICollectionViewLayoutAttributes]) {
        var nowWidth: CGFloat = 0.0
        nowWidth = self.sectionInset.left
        layoutAttributes.forEach { attr in
            var nowFrame = attr.frame
            nowFrame.origin.x = nowWidth
            attr.frame = nowFrame
            nowWidth += nowFrame.size.width + self.minimumInteritemSpacing
        }
    }
}
