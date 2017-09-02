//
//  ViewController.swift
//  GMNav
//
//  Created by MacBook Pro on 8/26/17.
//  Copyright © 2017 ATAMAN Community. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    let navigationView = UINavigationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(navigationView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
            self.navigationView.navigateToCoordinate(location: CLLocationCoordinate2D(latitude:37.564754, longitude: -122.329660)) //Simulator
            //self.navigationView.navigateToCoordinate(location: CLLocationCoordinate2D(latitude:49.945990, longitude: 36.312958)) //Kharkiv
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.navigationView.frame = self.view.bounds
    }
}

