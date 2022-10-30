//
//  TagViewController.swift
//  CollectionViewLayoutKit_Example
//
//  Created by tanxl on 2022/3/5.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import CollectionViewLayoutKit
import MJRefresh
import SnapKit

class TagViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    lazy var collectionView: UICollectionView = {
        let layout = TagLayout()
        layout.delegate = self
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
            sectionRow = Int(arc4random() % 10 + 10)
            for row in 0..<sectionRow {
                var height = arc4random() % 50 + 50
                if row == 3 {
                    height = 500
                }
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

extension TagViewController: TagLayoutDelegate {
    
    func tagLayout(_ layout: TagLayout, sizeForItem indexPath: NSIndexPath) -> CGSize {
        if indexPath.section < dataSource.count {
            let sectionNums: [CGFloat] = dataSource[indexPath.section]
            if indexPath.row < sectionNums.count {
                return CGSize(width: sectionNums[indexPath.row], height: 50)
            }
        }
        assert(false, "")
        return .zero
    }
    
    func tagLayout(_ layout: TagLayout, headerReferenceSize section: Int) -> CGFloat {
        if section == 0 {
            return 50
        }
        return 20
    }
    
    func tagLayout(_ layout: TagLayout, footerReferenceSize section: Int) -> CGFloat {
        if section == 0 {
            return 20
        }
        return 10
    }
    
    func tagLayout(_ layout: TagLayout, sectionReferenceInset section: Int) -> UIEdgeInsets {
        if section == 0 {
            return .zero
        }
        return UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
    func tagLayout(_ layout: TagLayout, minimumLineSpacing section: Int) -> CGFloat {
        10
    }
    
    func tagLayout(_ layout: TagLayout, minimumInteritemSpacing section: Int) -> CGFloat {
        10
    }
}
