//
//  FlowLayoutVerticalController.swift
//  CollectionViewLayoutKit_Example
//
//  Created by tanxl on 2022/3/2.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import CollectionViewLayoutKit
import MJRefresh
import SnapKit

class FlowLayoutVerticalController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    lazy var collectionView: UICollectionView = {
        let layout = FlowLayout()
        layout.delegate = self
        layout.scrollDirection = .vertical
        let w = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        w.showsVerticalScrollIndicator = true
        w.showsHorizontalScrollIndicator = false
        w.delegate = self
        w.dataSource = self
        w.register(TestCell.self, forCellWithReuseIdentifier: "\(TestCell.self)")
        w.register(TestHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "\(TestHeader.self)")
        w.register(TestFooter.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "\(TestFooter.self)")
        return w
    }()
    
    var dataSource: [[CGFloat]] = [[CGFloat]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        
        if #available(iOS 11, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            
        }
        
        let contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(contentInset)
        }
        
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        loadData()
        
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadData))
        collectionView.mj_header = header
        header.ignoredScrollViewContentInsetTop = contentInset.top

        let footer = MJRefreshBackFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        collectionView.mj_footer = footer
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    @objc func loadData() {
        data(false)
    }
    
    @objc func loadMore(){
        data(true)
    }
    
    @objc func data(_ ismore: Bool) {
        if ismore == false {
            dataSource.removeAll()
        }
        let sections = 5
        var sectionRow = 0
        for _ in 0..<sections {
            var datas: [CGFloat] = [CGFloat]()
            sectionRow = Int(arc4random() % 10 + 5)
            for _ in 0..<sectionRow {
                let height = arc4random() % 100 + 50
                datas.append(CGFloat(height))
            }
            dataSource.append(datas)
        }
        
        collectionView.reloadData()
        if ismore {
            collectionView.mj_footer?.endRefreshing()
        } else {
            collectionView.mj_header?.endRefreshing()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TestCell.self)", for: indexPath)
        cell.contentView.backgroundColor = .cyan
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? TestCell else {
            return
        }
        var height: CGFloat = 0.0
        if indexPath.section < dataSource.count {
            let sectionNums: [CGFloat] = dataSource[indexPath.section]
            if indexPath.row < sectionNums.count {
                height = sectionNums[indexPath.row]
            }
        }
        let string = "s:\(indexPath.section),r:\(indexPath.row)\nh:\(height)"
        cell.titleLabel.text = string
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView: UICollectionReusableView?
        if kind == UICollectionElementKindSectionHeader {
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "\(TestHeader.self)", for: indexPath)
            reusableView?.backgroundColor = .orange
        } else if kind == UICollectionElementKindSectionFooter {
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "\(TestFooter.self)", for: indexPath)
            reusableView?.backgroundColor = .purple
        }
        guard let reusableView = reusableView  else {
            return UICollectionReusableView()
        }
        return reusableView
    }
}

extension FlowLayoutVerticalController: FlowLayoutDelegate {
    
    func flowLayout(_ layout: FlowLayout, columnOfSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if section == 1 {
            return 2
        }
        if section == 2 {
            return 3
        }
        return 4
    }
    
    func flowLayout(_ layout: FlowLayout, sizeForItem indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section < dataSource.count {
            let sectionNums: [CGFloat] = dataSource[indexPath.section]
            if indexPath.row < sectionNums.count {
                return sectionNums[indexPath.row]
            }
        }
        assert(false, "")
        return 0
    }
    
    func flowLayout(_ layout: FlowLayout, headerReferenceSize section: Int) -> CGFloat {
        20
    }
    
    func flowLayout(_ layout: FlowLayout, footerReferenceSize section: Int) -> CGFloat {
        20
    }
    
    func flowLayout(_ layout: FlowLayout, sectionReferenceInset section: Int) -> UIEdgeInsets {
        if section == 0 {
            return .zero
        }
        if section == 1 {
            return UIEdgeInsetsMake(10, 0, 10, 0)
        }
        if section == 2 {
            return UIEdgeInsetsMake(0, 10, 0, 10)
        }
        return .zero
    }
    
    func flowLayout(_ layout: FlowLayout, minimumLineSpacing section: Int) -> CGFloat {
        10
    }
    
    func flowLayout(_ layout: FlowLayout, minimumInteritemSpacing section: Int) -> CGFloat {
        10
    }
}

class TestCell: UICollectionViewCell {
    
    var titleLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        contentView.backgroundColor = .white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = contentView.bounds
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class TestHeader: UICollectionReusableView {
    
}

class TestFooter: UICollectionReusableView {
    
}
