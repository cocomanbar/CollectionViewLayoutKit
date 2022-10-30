//
//  UICollectionViewLayout.swift
//  CollectionViewLayoutKit
//
//  Created by tanxl on 2022/3/5.
//

import Foundation

extension UICollectionViewLayout {
    
    /// 高度
    var height: CGFloat {
        collectionView?.frame.height ?? 0.0
    }
    
    /// 宽度
    var width: CGFloat {
        collectionView?.frame.width ?? 0.0
    }
    
    /// collectionView Inset
    var contentInset: UIEdgeInsets {
        collectionView?.contentInset ?? .zero
    }
    
}
