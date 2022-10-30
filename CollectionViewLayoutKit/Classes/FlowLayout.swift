//
//  WaterFlowLayout.swift
//  CollectionViewLayoutKit
//
//  Created by tanxl on 2022/3/2.
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
 
 
 单纯瀑布布局，即滚动方向上的等宽不等高布局
 目前实现的功能如下:
 a.每组可单独配置 组头组尾高度 组内边间距 瀑布流列数 item间距
 
*/

import UIKit

public protocol FlowLayoutDelegate: NSObjectProtocol {
    
    /// 列数（即滚动方向为主轴）
    func flowLayout(_ layout: FlowLayout, columnOfSection section: Int) -> Int
    
    /// item大小（即滚动方向为主轴）
    func flowLayout(_ layout: FlowLayout, sizeForItem indexPath: NSIndexPath) -> CGFloat
    
    /// 组头高度（即滚动方向为主轴）
    func flowLayout(_ layout: FlowLayout, headerReferenceSize section: Int) -> CGFloat
    
    /// 组尾高度（即滚动方向为主轴）
    func flowLayout(_ layout: FlowLayout, footerReferenceSize section: Int) -> CGFloat
    
    /// 组内边距（即滚动方向为主轴）
    func flowLayout(_ layout: FlowLayout, sectionReferenceInset section: Int) -> UIEdgeInsets
    
    /// 跟滚动方向相同的间距
    func flowLayout(_ layout: FlowLayout, minimumLineSpacing section: Int) -> CGFloat
    
    /// 跟滚动方向垂直的间距
    func flowLayout(_ layout: FlowLayout, minimumInteritemSpacing section: Int) -> CGFloat
}

open class FlowLayout: UICollectionViewLayout {
    
    public weak var delegate: FlowLayoutDelegate?
    
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical
    
    /// 列表内容的长度
    lazy var contentLength: CGFloat = 0
    /// 当前需要的布局对象
    lazy var layoutAttributes = [UICollectionViewLayoutAttributes]()
    /// 垂直滚动时-保存每组内各列的最大值y
    lazy var verticalSections = [Int: [CGFloat]]()
    /// 水平滚动时-保存每组内各列的最大值x
    lazy var horizontalSections = [Int: [CGFloat]]()
    
    /// 初始化 生成每个视图的布局信息
    open override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        contentLength = 0
        layoutAttributes.removeAll()
        verticalSections.removeAll()
        horizontalSections.removeAll()
        
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
    
    /// 返回indexPath位置cell对应的布局属性
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let cellAttributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
        var rect: CGRect = .zero
        switch scrollDirection {
        case .vertical:
            rect = flowVerticalLayoutAttributesFrameOfCell(at: indexPath)
        case .horizontal:
            rect = flowHorizontalLayoutAttributesFrameOfCell(at: indexPath)
        }
        cellAttributes.frame = rect
        return cellAttributes
    }
    
    /// 返回头和脚视图对应的布局属性
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: elementKind, with: indexPath)
        var rect: CGRect = .zero
        switch scrollDirection {
        case .vertical:
            if elementKind == UICollectionElementKindSectionHeader {
                rect = flowVerticalLayoutAttributesFrameOfHeader(at: indexPath)
            } else {
                rect = flowVerticalLayoutAttributesFrameOfFooter(at: indexPath)
            }
        case .horizontal:
            if elementKind == UICollectionElementKindSectionHeader {
                rect = flowHorizontalLayoutAttributesFrameOfHeader(at: indexPath)
            } else {
                rect = flowHorizontalLayoutAttributesFrameOfFooter(at: indexPath)
            }
        }
        attributes.frame = rect
        return attributes
    }
    
    /// 返回内容的大小
    open override var collectionViewContentSize: CGSize {
        var size: CGSize = .zero
        switch scrollDirection {
        case .vertical:
            size = CGSize(width: self.width - contentInset.left - contentInset.right, height: contentLength)
        case .horizontal:
            size = CGSize(width: contentLength, height: self.height - contentInset.top - contentInset.bottom)
        }
        return size
    }
}

// MARK: - 垂直滚动布局样式
extension FlowLayout {
    
    /// header布局信息vertical
    private func flowVerticalLayoutAttributesFrameOfHeader(at indexPath: IndexPath) -> CGRect{
        var view_x: CGFloat = 0
        var view_y: CGFloat = 0
        var view_w: CGFloat = 0
        var view_h: CGFloat = 0
        
        let sectionColumn = max(1, (delegate?.flowLayout(self, columnOfSection: indexPath.section) ?? 1))
        
        // 0.获取默认
        view_x = 0
        view_w = self.width - contentInset.left - contentInset.right
        
        // 1.计算view_h
        view_h = delegate?.flowLayout(self, headerReferenceSize: indexPath.section) ?? 0.0
        
        // 2.计算view_y
        view_y = contentLength
        
        // 3.更新内容高度
        contentLength = view_y + view_h
        
        // 更新这组的列的最低y值
        var currentSectionPoints: [CGFloat] = [CGFloat]()
        for _ in 0..<sectionColumn {
            currentSectionPoints.append(contentLength)
        }
        verticalSections[indexPath.section] = currentSectionPoints

        return CGRect(x: view_x, y: view_y, width: view_w, height: view_h)
    }
    
    /// cell布局信息vertical
    private func flowVerticalLayoutAttributesFrameOfCell(at indexPath: IndexPath) -> CGRect{
        var view_x: CGFloat = 0
        var view_y: CGFloat = 0
        var view_w: CGFloat = 0
        var view_h: CGFloat = 0
        
        let width = self.width
        
        // 1.计算view_w（总宽 - sectionInset.left - sectionInset.right - contentInset.left - contentInset.right - (列数n-1) * spacing）/ 列数n
        let sectionInset = delegate?.flowLayout(self, sectionReferenceInset: indexPath.section) ?? .zero
        let sectionColumn = max(1, (delegate?.flowLayout(self, columnOfSection: indexPath.section) ?? 1))
        let minimumLineSpacing = delegate?.flowLayout(self, minimumLineSpacing: indexPath.section) ?? 0
        let minimumInteritemSpacing = delegate?.flowLayout(self, minimumInteritemSpacing: indexPath.section) ?? 0
        view_w = (width - sectionInset.left - sectionInset.right - contentInset.left - contentInset.right - (CGFloat(sectionColumn) - 1) * minimumInteritemSpacing) / CGFloat(sectionColumn)
        
        // 2.计算view_h
        view_h = delegate?.flowLayout(self, sizeForItem: indexPath as NSIndexPath) ?? 0
        
        // 3.找出跟滚动方向相同的高度最短的那一列
        var destColumn: Int = 0
        var currentSectionPoints: [CGFloat] = verticalSections[indexPath.section] ?? [CGFloat]()
        var minColumnPoint: CGFloat = currentSectionPoints.first ?? 0.0
        for i in 1..<sectionColumn {
            var columnPoint: CGFloat = 0
            if i < currentSectionPoints.count {
                columnPoint = currentSectionPoints[i]
            } else {
                currentSectionPoints.append(0) // 补充够数
            }
            if minColumnPoint > columnPoint {
                minColumnPoint = columnPoint
                destColumn = i
            }
        }
        
        // 4.计算view_x
        view_x = sectionInset.left + CGFloat(destColumn) * ( view_w + minimumLineSpacing )
        
        // 5.计算view_y
        view_y = minColumnPoint
        // 5.1需要考虑靠近header时的问题，所以只要 indexPath.row 大于或等于该组列数 就需要加上间隙
        if indexPath.row >= sectionColumn {
            view_y += minimumInteritemSpacing
        } else {
            view_y += sectionInset.top
        }
        
        // 6.更新与滚动方向上最短那列的高度
        currentSectionPoints[destColumn] = view_y + view_h
        
        // 7.更新回去源数组
        verticalSections[indexPath.section] = currentSectionPoints
        
        // 8.记录内容的高度
        let columnHeight = currentSectionPoints[destColumn]
        if contentLength < columnHeight {
            contentLength = columnHeight
        }

        return CGRect(x: view_x, y: view_y, width: view_w, height: view_h)
    }
    
    /// footer布局信息vertical
    private func flowVerticalLayoutAttributesFrameOfFooter(at indexPath: IndexPath) -> CGRect{
        var view_x: CGFloat = 0
        var view_y: CGFloat = 0
        var view_w: CGFloat = 0
        var view_h: CGFloat = 0
        
        let sectionColumn = max(1, (delegate?.flowLayout(self, columnOfSection: indexPath.section) ?? 1))
        let sectionInset = delegate?.flowLayout(self, sectionReferenceInset: indexPath.section) ?? .zero
        
        // 0.获取默认
        view_x = 0
        view_w = self.width - contentInset.left - contentInset.right
        
        // 1.计算view_h
        view_h = delegate?.flowLayout(self, footerReferenceSize: indexPath.section) ?? 0
        
        // 2.计算view_y
        view_y = contentLength + sectionInset.bottom
        
        // 3.更新内容高度
        contentLength = view_y + view_h
        
        // 更新这组的列的最低y值
        var currentSectionPoints: [CGFloat] = [CGFloat]()
        for _ in 0..<sectionColumn {
            currentSectionPoints.append(contentLength)
        }
        verticalSections[indexPath.section] = currentSectionPoints

        return CGRect(x: view_x, y: view_y, width: view_w, height: view_h)
    }
}

// MARK: - 水平滚动布局样式
extension FlowLayout {
    
    /// header布局信息horizontal
    private func flowHorizontalLayoutAttributesFrameOfHeader(at indexPath: IndexPath) -> CGRect{
        var view_x: CGFloat = 0
        var view_y: CGFloat = 0
        var view_w: CGFloat = 0
        var view_h: CGFloat = 0
        
        let height = self.height - contentInset.top - contentInset.bottom
        let sectionColumn = max(1, (delegate?.flowLayout(self, columnOfSection: indexPath.section) ?? 1))
        
        view_x = contentLength
        view_y = 0
        view_w = delegate?.flowLayout(self, headerReferenceSize: indexPath.section) ?? 0.0
        view_h = height
        
        // 1.2更新contentLength
        contentLength = view_x + view_w
        
        // 1.3更新组内各列最大值x
        var currentSectionPoints: [CGFloat] = [CGFloat]()
        for _ in 0..<sectionColumn {
            currentSectionPoints.append(contentLength)
        }
        horizontalSections[indexPath.section] = currentSectionPoints
        
        return CGRect(x: view_x, y: view_y, width: view_w, height: view_h)
    }
    
    /// cell布局信息horizontal
    private func flowHorizontalLayoutAttributesFrameOfCell(at indexPath: IndexPath) -> CGRect{
        var view_x: CGFloat = 0
        var view_y: CGFloat = 0
        var view_w: CGFloat = 0
        var view_h: CGFloat = 0
        
        let height = self.height
        let sectionInset = delegate?.flowLayout(self, sectionReferenceInset: indexPath.section) ?? .zero
        let sectionColumn = max(1, (delegate?.flowLayout(self, columnOfSection: indexPath.section) ?? 1))
        let minimumLineSpacing = delegate?.flowLayout(self, minimumLineSpacing: indexPath.section) ?? 0
        let minimumInteritemSpacing = delegate?.flowLayout(self, minimumInteritemSpacing: indexPath.section) ?? 0
        
        // 2.计算固定高度（总高 - sectionInset.top - sectionInset.bottom - contentInset.top - contentInset.bottom - (列数n-1) * spacing）/ 列数n
        view_h = (height - sectionInset.top - sectionInset.bottom - contentInset.top - contentInset.bottom - (CGFloat(sectionColumn) - 1) * minimumInteritemSpacing) / CGFloat(sectionColumn)
        
        // 2.计算动态宽度
        view_w = delegate?.flowLayout(self, sizeForItem: indexPath as NSIndexPath) ?? 0
        
        // 3.找出组内最短的那列
        var destColumn: Int = 0
        var currentSectionPoints: [CGFloat] = horizontalSections[indexPath.section] ?? [CGFloat]()
        var minColumnPoint: CGFloat = currentSectionPoints.first ?? 0.0
        for i in 1..<sectionColumn {
            var columnPoint: CGFloat = 0
            if i < currentSectionPoints.count {
                columnPoint = currentSectionPoints[i]
            } else {
                currentSectionPoints.append(0) // 补充够数
            }
            if minColumnPoint > columnPoint {
                minColumnPoint = columnPoint
                destColumn = i
            }
        }

        // 4.计算view_y
        view_y = sectionInset.top + CGFloat(destColumn) * ( view_h + minimumLineSpacing )
        
        // 5.计算view_x
        view_x = minColumnPoint
        // 5.1需要考虑靠近header时的问题，所以只要 indexPath.row 大于或等于该组列数 就需要加上间隙
        if indexPath.row >= sectionColumn {
            view_x += minimumInteritemSpacing
        } else {
            view_x += sectionInset.top
        }

        // 6.更新与滚动方向上最短那列的高度
        currentSectionPoints[destColumn] = view_x + view_w

        // 7.更新回去源数组
        horizontalSections[indexPath.section] = currentSectionPoints

        // 8.记录内容的高度
        let columnHeight = currentSectionPoints[destColumn]
        if contentLength < columnHeight {
            contentLength = columnHeight
        }
        
        return CGRect(x: view_x, y: view_y, width: view_w, height: view_h)
    }
    
    /// footer布局信息horizontal
    private func flowHorizontalLayoutAttributesFrameOfFooter(at indexPath: IndexPath) -> CGRect{
        var view_x: CGFloat = 0
        var view_y: CGFloat = 0
        var view_w: CGFloat = 0
        var view_h: CGFloat = 0
        
        let height = self.height - contentInset.top - contentInset.bottom
        let sectionInset = delegate?.flowLayout(self, sectionReferenceInset: indexPath.section) ?? .zero
        let sectionColumn = max(1, (delegate?.flowLayout(self, columnOfSection: indexPath.section) ?? 1))
        
        view_x = contentLength + sectionInset.right
        view_y = 0
        view_w = delegate?.flowLayout(self, footerReferenceSize: indexPath.section) ?? 0.0
        view_h = height
        
        // 1.3更新contentLength
        contentLength = view_x + view_w
        // 1.4更新组内各列最大值x
        var currentSectionPoints: [CGFloat] = [CGFloat]()
        for _ in 0..<sectionColumn {
            currentSectionPoints.append(contentLength)
        }
        horizontalSections[indexPath.section] = currentSectionPoints
        
        return CGRect(x: view_x, y: view_y, width: view_w, height: view_h)
    }
}
