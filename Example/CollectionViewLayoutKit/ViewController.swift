//
//  ViewController.swift
//  CollectionViewLayoutKit
//
//  Created by tanxl on 03/02/2022.
//  Copyright (c) 2022 tanxl. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = .white
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //FlowLayoutHorizontalController
        //FlowLayoutVerticalController
        //NormalLayoutHorizontalController
        //TagViewController
        navigationController?.pushViewController(FlowLayoutVerticalController(), animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


