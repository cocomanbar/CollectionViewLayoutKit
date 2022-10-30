//
//  NormalLayoutHorizontalController.swift
//  CollectionViewLayoutKit_Example
//
//  Created by tanxl on 2022/3/3.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import CollectionViewLayoutKit
import MJRefresh

class NormalLayoutHorizontalController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var isHorizontal: Bool = true
    
    lazy var layout = UICollectionViewFlowLayout()
    
    lazy var collectionView: UICollectionView = {
        let layout = layout
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        let w = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        w.backgroundColor = .white
        w.showsHorizontalScrollIndicator = true
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
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadData()
        collectionView.reloadData()
        
        collectionView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        
        let item = UIBarButtonItem(title: "切换", style: .plain, target: self, action: #selector(changed))
        navigationItem.rightBarButtonItem = item
        
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadData))
        collectionView.mj_header = header
        header.ignoredScrollViewContentInsetTop = collectionView.contentInset.top
        
        let footer = MJRefreshBackFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        collectionView.mj_footer = footer
    }
    
    @objc func changed() {
        isHorizontal = !isHorizontal
        layout.scrollDirection = isHorizontal ? .horizontal : .vertical
        loadData()
        collectionView.reloadData()
        
        print("collectionView \(collectionView.frame)")
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
            sectionRow = Int(arc4random() % 20 + 5)
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
        let string = "s:\(indexPath.section),r:\(indexPath.row)\nh:\(height)\nrect:\(cell.frame)"
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: (collectionView.frame.width - 10) / 2.0, height: (collectionView.frame.height - 10) / 2.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if isHorizontal {
            return CGSize(width: 50, height: collectionView.frame.height)
        } else {
            return CGSize(width: collectionView.frame.width, height: 50)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if isHorizontal {
            return CGSize(width: 20, height: collectionView.frame.height)
        } else {
            return CGSize(width: collectionView.frame.width, height: 20)
        }
    }
}
