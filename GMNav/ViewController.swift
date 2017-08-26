//
//  ViewController.swift
//  GMNav
//
//  Created by MacBook Pro on 8/26/17.
//  Copyright © 2017 ATAMAN Community. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let navigationView = UINavigationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(navigationView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.navigationView.frame = self.view.bounds
    }
}

