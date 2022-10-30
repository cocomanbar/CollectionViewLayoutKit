//
//  TagLayout.swift
//  CollectionViewLayoutKit
//
//  Created by tanxl on 2022/3/5.
//

/*
 
                           _ooOoo_
                          o8888888o
                          88" . "88
                          (| -_- |)
                          O\  =  /O
                       ____/`---'\____
                     .'  \\|     |//  `.
                    /  \\|||  :  |||//  \
                   /  _||||| -:- |||||-  \
                   |   | \\\  -  /// |   |
                   | \_|  ''\---/''  |   |
                   \  .-\__  `-`  ___/-. /
                 ___`. .'  /--.--\  `. . __
              ."" '<  `.___\_<|>_/___.'  >'"".
             | | :  `- \`.;`\ _ /`;.`/ - ` : | |
             \  \ `-.   \_ __\ /__ _/   .-` /  /
        ======`-.____`-.___\_____/___.-`____.-'======
                           `=---='
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                 佛祖保佑              永无BUG
 
 
 组内流式标签
 目前实现的功能如下:
 a.每组可单独配置 标签高度、组头高度、组尾高度、item间距、组内边间距
 
*/
import UIKit

public protocol TagLayoutDelegate: NSObjectProtocol {
    
    /// item宽高，每组组内标签固定高度
    func tagLayout(_ layout: TagLayout, sizeForItem indexPath: NSIndexPath) -> CGSize
    
    /// 组头高度
    func tagLayout(_ layout: TagLayout, headerReferenceSize section: Int) -> CGFloat
    
    /// 组尾高度
    func tagLayout(_ layout: TagLayout, footerReferenceSize section: Int) -> CGFloat
    
    /// 组内边距
    func tagLayout(_ layout: TagLayout, sectionReferenceInset section: Int) -> UIEdgeInsets
    
    /// 跟滚动方向相同的间距
    func tagLayout(_ layout: TagLayout, minimumLineSpacing section: Int) -> CGFloat
    
    /// 跟滚动方向垂直的间距
    func tagLayout(_ layout: TagLayout, minimumInteritemSpacing section: Int) -> CGFloat
}

open class TagLayout: UICollectionViewLayout {
    
    public weak var delegate: TagLayoutDelegate?
        
    /// 列表内容的长度
    lazy var contentLength: CGFloat = 0
    /// 当前需要的布局对象
    lazy var layoutAttributes = [UICollectionViewLayoutAttributes]()
    /// 记录每组约束的最后一次标签
    lazy var sectionTagFrames = [Int: CGRect]()
    
    /// 初始化 生成每个视图的布局信息
    open override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        contentLength = 0
        layoutAttributes.removeAll()
        sectionTagFrames.removeAll()
        
        // 当前总共的组数
        let sectionCount = collectionView.numberOfSections;
        
        // 创建布局属性，获取顺序依次是header - cell - footer
        for section in 0..<sectionCount {
            let indexPath = NSIndexPath(item: 0, section: section)
            if let headerAttributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: indexPath as IndexPath) {
                layoutAttributes.append(headerAttributes)
            }
            let rowCount = collectionView.numberOfItems(inSection: section)
            for row in 0..<rowCount {
                let indexPath = NSIndexPath(item: row, section: section)
                if let cellAttributes = self.layoutAttributesForItem(at: indexPath as IndexPath) {
                    layoutAttributes.append(cellAttributes)
                }
            }
            if let footerAttributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionFooter, at: indexPath as IndexPath) {
                layoutAttributes.append(footerAttributes)
            }
        }
    }
    
    /// 决定这一段区间内的布局信息
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        layoutAttributes
    }
    
    /// 返回内容的大小
    open override var collectionViewContentSize: CGSize {
        CGSize(width: self.width - contentInset.left - contentInset.right, height: contentLength)
    }
    
    /// 返回indexPath位置cell对应的布局属性
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let cellAttributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
        cellAttributes.frame = TagLayoutAttributesFrameOfCell(at: indexPath)
        return cellAttributes
    }
    
    /// 返回头和脚视图对应的布局属性
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: elementKind, with: indexPath)
        if elementKind == UICollectionElementKindSectionHeader {
            attributes.frame = TagLayoutAttributesFrameOfHeader(at: indexPath)
        } else {
            attributes.frame = TagLayoutAttributesFrameOfFooter(at: indexPath)
        }
        return attributes
    }
    
}

extension TagLayout {
    
    /// header布局信息vertical
    private func TagLayoutAttributesFrameOfHeader(at indexPath: IndexPath) -> CGRect{
        var view_x: CGFloat = 0
        var view_y: CGFloat = 0
        var view_w: CGFloat = 0
        var view_h: CGFloat = 0
        
        // 0.获取默认
        view_x = 0
        view_w = self.width - contentInset.left - contentInset.right
        
        // 1.计算view_h
        view_h = delegate?.tagLayout(self, headerReferenceSize: indexPath.section) ?? 0.0
        
        // 2.计算view_y
        view_y = contentLength
        
        // 3.更新内容高度
        contentLength = view_y + view_h
        
        return CGRect(x: view_x, y: view_y, width: view_w, height: view_h)
    }
    
    /// cell布局信息vertical
    private func TagLayoutAttributesFrameOfCell(at indexPath: IndexPath) -> CGRect{
        var view_x: CGFloat = 0
        var view_y: CGFloat = 0
        var view_w: CGFloat = 0
        var view_h: CGFloat = 0
        
        let sectionInset = delegate?.tagLayout(self, sectionReferenceInset: indexPath.section) ?? .zero
        let minimumLineSpacing = delegate?.tagLayout(self, minimumLineSpacing: indexPath.section) ?? 0
        let minimumInteritemSpacing = delegate?.tagLayout(self, minimumInteritemSpacing: indexPath.section) ?? 0
        let contentWidth = self.width - contentInset.left - contentInset.right - sectionInset.left - sectionInset.right
        
        // 1.计算view_w
        let size = delegate?.tagLayout(self, sizeForItem: indexPath as NSIndexPath) ?? .zero
        
        // 2.记录当前组的高度标准
        view_h = size.height
        if let rect = sectionTagFrames[indexPath.section] {
            view_h = rect.height
        }
                
        // 4.计算view_w
        view_w = size.width
        
        // 3.找出组内上一个layout信息
        let lastRect: CGRect = sectionTagFrames[indexPath.section] ?? .zero
        
        // 上一个标签maxX + 间距 + 当前的标宽度 > 宽 则需要换行
        if lastRect.maxX + minimumInteritemSpacing + view_w > contentWidth {
            // 单个标签占一行
            if view_w >= contentWidth {
                view_w = contentWidth
                view_x = sectionInset.left
                view_y += (lastRect.maxY + minimumLineSpacing)
            } else {
                view_x = sectionInset.left
                view_y += (lastRect.maxY + minimumLineSpacing)
            }
        } else {
            // 如果上一个标签没有则是刚开始
            if __CGSizeEqualToSize(.zero, lastRect.size) {
                view_x = sectionInset.left
                view_y = sectionInset.top + contentLength
            } else {
                view_x = lastRect.maxX + minimumInteritemSpacing
                view_y = lastRect.origin.y
            }
        }

        // 3.更新内容高度
        contentLength = view_y + view_h
        
        let currentRect = CGRect(x: view_x, y: view_y, width: view_w, height: view_h)
        sectionTagFrames[indexPath.section] = currentRect
        
        return currentRect
    }
    
    /// footer布局信息vertical
    private func TagLayoutAttributesFrameOfFooter(at indexPath: IndexPath) -> CGRect{
        var view_x: CGFloat = 0
        var view_y: CGFloat = 0
        var view_w: CGFloat = 0
        var view_h: CGFloat = 0
        
        let sectionInset = delegate?.tagLayout(self, sectionReferenceInset: indexPath.section) ?? .zero
        
        // 0.获取默认
        view_x = 0
        view_w = self.width - contentInset.left - contentInset.right
        
        // 1.计算view_h
        view_h = delegate?.tagLayout(self, footerReferenceSize: indexPath.section) ?? 0
        
        // 2.计算view_y
        view_y = contentLength + sectionInset.bottom
        
        // 3.更新内容高度
        contentLength = view_y + view_h

        return CGRect(x: view_x, y: view_y, width: view_w, height: view_h)
    }
}
